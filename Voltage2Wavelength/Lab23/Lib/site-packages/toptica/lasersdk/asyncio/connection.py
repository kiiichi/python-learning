import asyncio
import logging
import re
import socket
import sys

from asyncio import StreamReader
from asyncio import StreamWriter

from ipaddress import IPv4Address
from ipaddress import IPv4Network
from ipaddress import IPv6Address
from ipaddress import ip_address

from abc import ABC
from abc import abstractmethod

from typing import Optional
from typing import Tuple
from typing import Union
from typing import cast

import ifaddr  # type: ignore
import serial  # type: ignore

from ..decop import DecopError

__all__ = ['Connection', 'NetworkConnection', 'SerialConnection', 'BufferOverflowError', 'ConnectionClosedError',
           'DecopError', 'DeviceNotFoundError', 'UnavailableError']


# The maximum allowed size of a message from a device before an exception is raised
MAX_STREAM_READER_RESPONSE = 8*1024*1024  # 8 MiB

# Type alias for the IP address, command line port and monitoring line port of a DeCoP network device
DeviceNetworkAddress = Tuple[Union[IPv4Address, IPv6Address], int, int]


class DeviceNotFoundError(DecopError):
    """An exception that is raised when connecting to a device has failed."""


class BufferOverflowError(DecopError):
    """An exception that is raised when the amount of received data exceeds the size of the internal buffer."""


class UnavailableError(DecopError):
    """An exception that is raised when a command line or monitoring line is used that is not available."""


class ConnectionClosedError(DecopError):
    """An exception that is raised when a connection is closed."""


class Connection(ABC):
    """An abstract base class for connection objects."""
    @abstractmethod
    async def open(self) -> None:
        """Opens the connection to a device."""
        raise NotImplementedError

    @abstractmethod
    async def close(self) -> None:
        """Closes the connection to a device."""
        raise NotImplementedError

    @abstractmethod
    async def read_command_line(self) -> str:
        """Reads a message from the command line of the device."""
        raise NotImplementedError

    @abstractmethod
    async def write_command_line(self, message: str) -> None:
        """Writes a message to the monitoring line of the device."""
        raise NotImplementedError

    @abstractmethod
    async def read_monitoring_line(self) -> str:
        """Reads a message from the monitoring line of the device."""
        raise NotImplementedError

    @abstractmethod
    async def write_monitoring_line(self, message: str) -> None:
        """Writes a message to the monitoring line of the device."""
        raise NotImplementedError

    @property
    @abstractmethod
    def timeout(self) -> float:
        """float: The timeout value (in seconds) of the connection."""
        raise NotImplementedError

    @property
    @abstractmethod
    def is_open(self) -> bool:
        """bool: True if the connection is open, False otherwise."""
        raise NotImplementedError

    @property
    @abstractmethod
    def command_line_available(self) -> bool:
        """bool: True if the command line is available, False otherwise."""
        raise NotImplementedError

    @property
    @abstractmethod
    def monitoring_line_available(self) -> bool:
        """bool: True if the monitoring line is available, False otherwise."""
        raise NotImplementedError

    @property
    @abstractmethod
    def loop(self) -> asyncio.AbstractEventLoop:
        """AbstractEventLoop: The event loop used by the connection."""
        raise NotImplementedError


class DiscoveryProtocol(asyncio.DatagramProtocol):
    """An implementation of a DatagramProtocol for device discovery.

    Attributes:
        device_name (str): The serial number or system label of the device.

    """

    def __init__(self, device_name: str) -> None:
        self._logger = logging.getLogger(__name__)
        self._device_name = device_name
        self._regex = re.compile(r'\("(.*?)" "(.*?)" "(.*?)" "(.*?)" "(.*?)" "(.*?)" (\d+) "(.*?)" (\d+) (\d+)\)')
        self._result: asyncio.Future[DeviceNetworkAddress] = asyncio.Future()

    def connection_made(self, transport: asyncio.BaseTransport) -> None:
        for adapter in ifaddr.get_adapters():
            for ip in adapter.ips:
                if ip.is_IPv4:
                    net = IPv4Network(f"{ip.ip}/{ip.network_prefix}", strict=False)
                    if not net.is_link_local and not net.is_loopback:
                        transport.sendto(b'whoareyou?', (str(net.broadcast_address), 60010))  # type: ignore

    def datagram_received(self, data: bytes, addr: Tuple[str, int]) -> None:
        string = data.decode('utf-8', 'replace')
        self._logger.debug('datagram_received: %s', string)
        match = self._regex.match(string)
        if match:
            ls = match.groups()
            if len(ls) == 10 and (ls[0] == self._device_name or ls[5] == self._device_name):
                self._result.set_result((ip_address(ls[7]), int(ls[8]), int(ls[9])))

    def error_received(self, exc: Exception):
        self._logger.error('DiscoveryProtocol: error_received: %s', str(exc))

    @property
    def result(self) -> 'asyncio.Future[DeviceNetworkAddress]':
        """asyncio.Future[DeviceNetworkAddress]: The result of the discovery process."""
        return self._result


class NetworkConnection(Connection):
    """A network connection to a device.

    Attributes:
        host (str): The IP address, DNS hostname, serial number or system label of the device.

        command_line_port (int): The TCP port of the command line (can be 0 if the command line is not
                                 required or supported by the device).

        monitoring_line_port (int): The TCP port of the monitoring line (can be 0 if the monitoring line is not
                                    required or supported by the device).

        timeout (float): The timeout (in seconds) of this connection.

    """

    def __init__(self, host: str, command_line_port: int = 1998, monitoring_line_port: int = 1999, timeout: float = 5) -> None:
        self._logger = logging.getLogger(__name__)
        self._host = host
        self._command_port = command_line_port
        self._monitoring_port = monitoring_line_port
        self._timeout = timeout
        self._loop = asyncio.get_event_loop()
        self._command_line_reader: Optional[StreamReader] = None
        self._command_line_writer: Optional[StreamWriter] = None
        self._monitoring_line_reader: Optional[StreamReader] = None
        self._monitoring_line_writer: Optional[StreamWriter] = None

    def __repr__(self) -> str:
        return f"<NetworkConnection host={self._host}:{self._command_port},{self._monitoring_port}>"

    async def __aenter__(self) -> 'NetworkConnection':
        await self.open()
        return self

    async def __aexit__(self, *args) -> None:
        await self.close()

    async def open(self) -> None:
        """Opens a network connection to the device.

        Raises:
            DeviceNotFoundError: If an invalid IP address was provided or no IP address could be found for
                                 the DNS hostname, serial number or system label.

        """
        if self.is_open:
            return

        # Use the event loop from the calling thread of this method
        self._loop = asyncio.get_event_loop()

        ip: Optional[Union[IPv4Address, IPv6Address]] = None

        try:
            # Try to parse as an IP address e.g. '192.168.1.32'
            ip = ip_address(self._host)
        except ValueError:
            try:
                # Try to resolve DNS hostname e.g. 'dlcpro.example.com'
                ip = ip_address(socket.gethostbyname(self._host))
            except (ValueError, OSError):
                # Try to find the device by either its serial number or system label
                network_address = await self.find_device(self._host, self._timeout)
                if network_address:
                    ip, self._command_port, self._monitoring_port = network_address

        if ip is None:
            raise DeviceNotFoundError(f"No valid IP address could be found for the host: '{self._host}'")

        # Compress an IPv6 address if possible (does nothing for IPv4)
        self._host = ip.compressed

        # Normalize invalid values for the command line and monitoring line ports
        if self._command_port is None:
            self._command_port = 0

        if self._monitoring_port is None:
            self._monitoring_port = 0

        self._logger.debug(
            "Opening network connection to '%s:%d,%d'", self._host, self._command_port, self._monitoring_port)

        # Try to open a connection to the command line
        if self._command_port != 0:
            try:
                self._command_line_reader, self._command_line_writer = \
                    await asyncio.open_connection(self._host, self._command_port, limit=MAX_STREAM_READER_RESPONSE)
            except OSError as error:
                await self.close()
                raise DeviceNotFoundError(error) from None

            try:
                # Purge the welcome message
                await asyncio.wait_for(self._command_line_reader.readuntil(b'\n> '), self._timeout)
            except (asyncio.TimeoutError, asyncio.IncompleteReadError):
                await self.close()
                raise DeviceNotFoundError('Timeout while waiting for the command line prompt') from None

        # Try to open a connection to the monitoring line
        if self._monitoring_port != 0:
            try:
                self._monitoring_line_reader, self._monitoring_line_writer = \
                    await asyncio.open_connection(self._host, self._monitoring_port, limit=MAX_STREAM_READER_RESPONSE)
            except OSError as error:
                await self.close()
                raise DeviceNotFoundError(error) from None

    async def close(self) -> None:
        """Closes the network connection."""
        if not self.is_open:
            return

        self._logger.debug("Closing network connection to '%s'", self._host)

        # Close the command line
        if self._command_line_writer is not None:
            self._command_line_writer.close()
            if sys.version_info >= (3, 7):
                await self._command_line_writer.wait_closed()
            self._command_line_writer = None
        self._command_line_reader = None

        # Close the monitoring line
        if self._monitoring_line_writer is not None:
            self._monitoring_line_writer.close()
            if sys.version_info >= (3, 7):
                await self._monitoring_line_writer.wait_closed()
            self._monitoring_line_writer = None
        self._monitoring_line_reader = None

    async def read_command_line(self) -> str:
        """Reads a message from the command line of the device.

        Returns:
            str: The message read from the command line.

        Raises:
            BufferOverflowError: If the amount of received data exceeds the size of the internal buffer.
            ConnectionClosedError: If the connection was closed either by calling close() or due to a network error.

        """
        if not self.is_open:
            raise UnavailableError(f"The network connection to '{self._host}' is closed.")

        if self._command_line_reader is None:
            raise UnavailableError(f"The command line is not available for '{self._host}'.")

        try:
            data = await self._command_line_reader.readuntil(b'\n> ')
        except asyncio.LimitOverrunError:
            raise BufferOverflowError('Received data exceeded the size of the internal buffer') from None
        except asyncio.IncompleteReadError:
            await self.close()
            raise ConnectionClosedError from None

        result = data.decode('utf-8', 'replace')

        if result.endswith('\r\n> '):
            self._logger.debug("%s:%d - CMD RX: %s", self._host, self._command_port, repr(result[:-4]))
            return result[:-4]
        else:
            self._logger.debug("%s:%d - CMD RX: %s", self._host, self._command_port, repr(result[:-3]))
            return result[:-3]

    async def write_command_line(self, message: str) -> None:
        """Sends a message to the command line.

        Args:
            message (str): The message to send to the command line.

        Raises:
            UnavailableError: If the connection is either closed or the command line is not available.

        """
        if not self.is_open:
            raise UnavailableError(f"The network connection to '{self._host}' is closed.")

        if self._command_line_writer is None:
            raise UnavailableError(f"The command line is not available for '{self._host}'.")

        self._logger.debug("%s:%d - CMD TX: %s", self._host, self._command_port, repr(message))

        self._command_line_writer.write(message.encode('utf-8'))
        await self._command_line_writer.drain()

    async def read_monitoring_line(self) -> str:
        """Reads a message from the monitoring line of the device.

        Returns:
            str: The message read from the monitoring line.

        Raises:
            UnavailableError: If the monitoring line is not available.
            BufferOverflowError:

        """
        if not self.is_open:
            raise UnavailableError(f"The network connection to '{self._host}' is closed.")

        if self._monitoring_line_reader is None:
            raise UnavailableError(f"The monitoring line is not available for '{self._host}'.")

        try:
            data = await self._monitoring_line_reader.readuntil(b'\n')
        except asyncio.LimitOverrunError:
            raise BufferOverflowError('Received data exceeded the size of the internal buffer') from None
        except asyncio.IncompleteReadError:
            await self.close()
            raise ConnectionClosedError from None

        result = data.decode('utf-8', 'replace')

        if result.endswith('\r\n'):
            self._logger.debug("%s:%d - MON RX: %s", self._host, self._monitoring_port, repr(result[:-2]))
            return result[:-2]
        else:
            self._logger.debug("%s:%d - MON RX: %s", self._host, self._monitoring_port, repr(result[:-1]))
            return result[:-1]

    async def write_monitoring_line(self, message: str) -> None:
        """Sends a message to the monitoring line.

        Args:
            message (str): The message to send to the monitoring line.

        Raises:
            BufferOverflowError: If the amount of received data exceeds the size of the internal buffer.
            ConnectionClosedError: If the connection was closed either by calling close() or due to a network error.

        """
        if not self.is_open:
            raise UnavailableError(f"The network connection to '{self._host}' is closed.")

        if self._monitoring_line_writer is None:
            raise UnavailableError(f"The monitoring line is not available for '{self._host}'.")

        self._logger.debug("%s:%d - MON TX: %s", self._host, self._monitoring_port, repr(message))

        self._monitoring_line_writer.write(message.encode('utf-8'))
        await self._monitoring_line_writer.drain()

    @property
    def timeout(self) -> float:
        """float: The timeout value (in seconds) of the connection."""
        return self._timeout

    @property
    def is_open(self) -> bool:
        """bool: True if the connection is open, False otherwise."""
        return self.command_line_available or self.monitoring_line_available

    @property
    def command_line_available(self) -> bool:
        """bool: True if the command line is available, False otherwise."""
        return self._command_line_writer is not None

    @property
    def monitoring_line_available(self) -> bool:
        """bool: True if the monitoring line is available, False otherwise."""
        return self._monitoring_line_writer is not None

    @property
    def loop(self) -> asyncio.AbstractEventLoop:
        """AbstractEventLoop: The event loop used by the connection."""
        return self._loop

    @staticmethod
    async def find_device(name: str, timeout: float = 5) -> Optional[DeviceNetworkAddress]:
        """Tries to find a device in the local network using its serial number or system label.

        Args:
            name (str): The serial number or system label of the device.

            timeout (int): The timeout for waiting for a response from the searched device.

        Returns:
            Optional[DeviceNetworkAddress]: A tuple containing the IP address and TCP ports of the device
                                            or None if the device could not be found.

        """
        loop = asyncio.get_event_loop()
        protocol = DiscoveryProtocol(name)

        transport, _ = \
            await loop.create_datagram_endpoint(lambda: protocol, local_addr=('0.0.0.0', 0), allow_broadcast=True)

        try:
            return await asyncio.wait_for(protocol.result, timeout)
        except asyncio.TimeoutError:
            return None
        finally:
            transport.close()


class SerialConnection(Connection):
    """A serial connection to a device.

    Attributes:
        port (str): The name of a serial port (e.g. 'COM1' or '/dev/ttyUSB0') or a pyserial
                    URL handler (https://pyserial.readthedocs.io/en/latest/url_handlers.html).

        baudrate (int): The number of transferred bits per second.

        timeout (float): The communication timeout (in seconds).

    """

    def __init__(self, port: str, baudrate: int = 115200, timeout: float = 5) -> None:
        self._logger = logging.getLogger(__name__)
        self._port = port
        self._baudrate = baudrate
        self._timeout = timeout
        self._loop = asyncio.get_event_loop()
        self._serial = serial.Serial()

    def __repr__(self) -> str:
        return f"<SerialConnection port={self._port} baudrate={self._baudrate}>"

    async def __aenter__(self) -> 'SerialConnection':
        await self.open()
        return self

    async def __aexit__(self, *args) -> None:
        await self.close()

    async def open(self) -> None:
        """Opens a serial connection to the device.

        Raises:
            DeviceNotFoundError: If connecting to the device failed.

        """
        if self.is_open:
            return

        try:
            self._logger.debug("Opening serial connection to '%s' with %d baud", self._port, self._baudrate)
            self._serial = serial.serial_for_url(self._port, baudrate=self._baudrate)
        except serial.serialutil.SerialException as ex:
            raise DeviceNotFoundError from ex

        # Use the event loop from the calling thread of this method
        self._loop = asyncio.get_event_loop()

        # Temporarily set shorter timeout
        self._serial.timeout = 0.5

        # Disable serial echo (\x12) and cancel the device interpreter state (\x03)
        await self.write_command_line('\x12\x03')

        # Purge the input buffer by reading a possible welcome message and the
        # prompt created by the cancel
        await self._loop.run_in_executor(None, lambda: self._serial.read_until(b'\n> '))  # type: ignore
        await self._loop.run_in_executor(None, lambda: self._serial.read_until(b'\n> '))  # type: ignore

        # Restore the original timeout
        self._serial.timeout = self._timeout

    async def close(self) -> None:
        """Closes the serial connection to the device."""
        if not self.is_open:
            return

        self._logger.debug("Closing the serial connection to '%s'", self._port)

        await self._loop.run_in_executor(None, self._serial.close)  # type: ignore

    async def read_command_line(self) -> str:
        """Reads a message from the command line of the device.

        Returns:
            str: The message read from the command line.

        Raises:
            UnavailableError: If the connection is closed.

        """
        if not self.is_open:
            raise UnavailableError(f"The serial connection to '{self._port}' is closed.")

        data = cast(bytes, await self._loop.run_in_executor(None, lambda: self._serial.read_until(b'\n> ')))  # type: ignore
        result = data.decode('utf-8', 'replace')

        if result.endswith('\r\n> '):
            self._logger.debug("%s - CMD RX: %s", self._port, repr(result[:-4]))
            return result[:-4]

        if result.endswith('\n> '):
            self._logger.debug("%s - CMD RX: %s", self._port, repr(result[:-3]))
            return result[:-3]

        await self.close()
        raise ConnectionClosedError

    async def write_command_line(self, message: str) -> None:
        """Sends a message to the command line.

        Args:
            message (str): The message to send to the command line.

        Raises:
            UnavailableError: If the connection is closed.

        """
        if not self.is_open:
            raise UnavailableError(f"The serial connection to '{self._port}' is closed.")

        self._logger.debug("%s - CMD TX: %s", self._port, repr(message))
        await self._loop.run_in_executor(None, lambda: self._serial.write(message.encode('utf-8')))  # type: ignore

    async def read_monitoring_line(self) -> str:
        """Reads a message from the monitoring line of the device.

        The monitoring line is not available on serial connections, therefore
        this method will always raise an UnavailableError.

        Returns:
            str: The message read from the monitoring line.

        Raises:
            UnavailableError: Always because the monitoring line is not available on serial connections.

        """
        raise UnavailableError('The monitoring line is not available on serial connections.')

    async def write_monitoring_line(self, message: str) -> None:
        """Sends a message to the monitoring line of the device.

        The monitoring line is not available on serial connections, therefore
        this method will always raise an UnavailableError.

        Args:
            message (str): The message to send to the monitoring line.

        Raises:
            UnavailableError: Always because the monitoring line is not available on serial connections.

        """
        raise UnavailableError('The monitoring line is not available on serial connections.')

    @property
    def timeout(self) -> float:
        """float: The timeout value (in seconds) of the connection."""
        return self._timeout

    @property
    def is_open(self) -> bool:
        """bool: True if the connection is open, False otherwise."""
        return cast(bool, self._serial.isOpen())

    @property
    def command_line_available(self) -> bool:
        """bool: True if the command line is available, False otherwise."""
        return self.is_open

    @property
    def monitoring_line_available(self) -> bool:
        """bool: Always False because the monitoring line is not available on serial connections."""
        return False

    @property
    def loop(self) -> asyncio.AbstractEventLoop:
        """AbstractEventLoop: The event loop used by the connection."""
        return self._loop
