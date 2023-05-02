import asyncio
import logging

from base64 import b64decode
from base64 import b64encode

from datetime import datetime

from typing import Dict
from typing import List
from typing import Optional
from typing import Tuple
from typing import Union
from typing import cast

from ..decop import UserLevel

from ..decop import decode_value
from ..decop import decode_value_inferred
from ..decop import encode_value
from ..decop import parse_monitoring_line

from ..decop import DecopError
from ..decop import DecopMetaType
from ..decop import DecopStreamMetaType
from ..decop import DecopStreamType
from ..decop import SubscriptionValue
from ..decop import Timestamp
from ..decop import DecopType
from ..decop import DecopValueError

from .connection import Connection
from .connection import NetworkConnection
from .connection import SerialConnection

from .connection import ConnectionClosedError
from .connection import DeviceNotFoundError
from .connection import UnavailableError

__all__ = ['UserLevel', 'Connection', 'Client', 'Subscription', 'SubscriptionValue',
           'NetworkConnection', 'SerialConnection',
           'DecopError', 'DecopValueError', 'DeviceNotFoundError',
           'DecopBoolean', 'MutableDecopBoolean', 'SettableDecopBoolean',
           'DecopInteger', 'MutableDecopInteger', 'SettableDecopInteger',
           'DecopReal', 'MutableDecopReal', 'SettableDecopReal',
           'DecopString', 'MutableDecopString', 'SettableDecopString',
           'DecopBinary', 'MutableDecopBinary', 'SettableDecopBinary']


class Client:
    """An asynchronous client for devices that support the Device Control Protocol (DeCoP).

    Attributes:
        connection (Connection): A connection that is used to communicate with the device.

    """

    def __init__(self, connection: Connection) -> None:
        self._logger = logging.getLogger(__name__)
        self._connection = connection
        self._subscriptions: Dict[str, Tuple[Optional[DecopMetaType], List[Subscription]]] = {}
        self._monitoring_line_task: Optional[asyncio.Task] = None

    async def __aenter__(self) -> 'Client':
        await self.open()
        return self

    async def __aexit__(self, *args) -> None:
        await self.close()

    async def open(self) -> None:
        """Opens a connection to the device.

        Raises:
            DeviceNotFoundError: If opening the connection to the device has failed.

        """
        await self._connection.open()

        # Create a task that handles all monitoring line updates if the connection has a monitoring line
        if self._monitoring_line_task is None and self._connection.monitoring_line_available:
            self._monitoring_line_task = asyncio.ensure_future(self._monitoring_line_handler())

    async def close(self) -> None:
        """Closes the connection to the device."""

        # Cancel the monitoring line handler task
        if self._monitoring_line_task is not None:
            self._monitoring_line_task.cancel()
            try:
                await self._monitoring_line_task
            except asyncio.CancelledError:
                self._monitoring_line_task = None

        # Cancel all subscriptions
        subscriptions: List[Subscription] = []

        for _, value in self._subscriptions.values():
            subscriptions += value

        for subscription in subscriptions:
            await subscription.cancel()

        # Close the connection
        await self._connection.close()
        self._subscriptions = {}

    async def change_ul(self, ul: UserLevel, password: Optional[str] = None) -> UserLevel:
        """Changes the user level of the client connection.

        Args:
            ul (UserLevel): The requested user level.
            password (Optional[str]): The password for the requested user level.

        Returns:
            UserLevel: The new user level or the previous one if the password was incorrect.

        Raises:
            UnavailableError: If the connection is closed.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if password is None:
            password = ""

        result = ul

        if self._connection.command_line_available:
            # Empty passwords are only allowed for UserLevel.NORMAL and UserLevel.READONLY
            if not password and ul != UserLevel.NORMAL and ul != UserLevel.READONLY:
                return UserLevel(cast(int, await self.get('ul', int)))

            # Change the user level for the command line
            result = UserLevel(cast(int, await self.exec('change-ul', int(ul), password, return_type=int)))

        # Change the user level for the monitoring line
        if self._connection.monitoring_line_available:
            await self._connection.write_monitoring_line(f'(change-ul {int(ul)} "{password}")\n')

        return result

    async def get(self, param_name: str, *param_types: DecopMetaType) -> DecopType:
        """Returns the current value of a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_types (DecopMetaType): Zero or more types of the DeCoP parameter.

        Returns:
            DecopType: The current value of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopValueError: If the provided types don't match the result from the device.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        await self._connection.write_command_line(f"(param-ref '{param_name})\n")
        result = await self._connection.read_command_line()

        if not param_types:
            return decode_value_inferred(result)

        if len(param_types) == 1:
            return decode_value(result, param_types[0])

        values = result[1:-1].split(' ')

        if len(values) == len(param_types):
            return tuple(decode_value(pair[0], pair[1]) for pair in zip(values, param_types))

        raise DecopError(f"Invalid type list: '{param_types}' for value '{values}'")

    async def get_set_value(self, param_name: str, *param_types: DecopMetaType) -> DecopType:
        """Returns the current 'set value' of a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_types (DecopMetaType): Zero or more types of the DeCoP parameter.

        Returns:
            DecopType: The 'set value' of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopValueError: If the provided types don't match the result from the device.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        await self._connection.write_command_line(f"(param-gsv '{param_name})\n")
        result = await self._connection.read_command_line()

        if not param_types:
            return decode_value_inferred(result)

        if len(param_types) == 1:
            return decode_value(result, param_types[0])

        values = result[1:-1].split(' ')

        if len(values) == len(param_types):
            return tuple(decode_value(pair[0], pair[1]) for pair in zip(values, param_types))

        raise DecopValueError(f"Invalid type list: '{param_types}' for value '{values}'")

    async def set(self, param_name: str, *param_values: DecopType) -> int:
        """Set a new value for a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_values (DecopType): One or more parameter values.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        values = [encode_value(x) for x in param_values]

        fmt = "(param-set! '{} {})\n" if len(values) == 1 else "(param-set! '{} '({}))\n"

        await self._connection.write_command_line(fmt.format(param_name, ' '.join(values)))
        result = await self._connection.read_command_line()

        # Skip any additional output before the status code
        result = result.splitlines()[-1]

        status = cast(int, decode_value(result, int))

        if status < 0:
            raise DecopError(f"Setting parameter '{param_name}' to '{param_values}' failed: '{status}'")

        return status

    async def exec(self, name: str, *args, input_stream: DecopStreamType = None,
                   output_type: DecopStreamMetaType = None, return_type: DecopMetaType = None) -> Optional[DecopType]:
        """Execute a DeCoP command.

        Args:
            name (str): The name of the command.
            *args: The parameters of the command.
            input_stream (DecopStreamType): The input stream data of the command.
            output_type (DecopStreamMetaType): The type of the output stream of the command.
            return_type (DecopMetaType): The type of the optional return value.

        Returns:
            Optional[DecopType]: Either the output stream, the return value or a tuple of both.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when executing the command.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        param_list = ''
        for param in args:
            param_list += ' ' + encode_value(param)
        await self._connection.write_command_line("(exec '" + name + param_list + ")\n")

        if isinstance(input_stream, str):
            await self._connection.write_command_line(input_stream + '#')
        elif isinstance(input_stream, bytes):
            await self._connection.write_command_line(b64encode(input_stream).decode('ascii') + '#')

        result = await self._connection.read_command_line()

        lines = str.splitlines(result, keepends=True)

        if not lines:
            raise DecopError("Missing response for command '" + name + "'")

        if lines[0].lower().startswith('error:'):
            # Error in the first line of the response: use the whole response as error message
            raise DecopError(result)

        if lines[-1].lower().startswith('error:'):
            # Error in the last line of the response: use only this line as error message
            raise DecopError(lines[-1])

        output_value: Optional[Union[bytes, str]] = None
        return_value: Optional[DecopType] = None

        if output_type is bytes:
            output_value = b64decode(''.join(lines[:-1]).encode())

        if output_type is str:
            output_value = ''.join(lines[:-1])

        if return_type is not None:
            return_value = decode_value(lines[-1], return_type)

        if output_type is not None and return_type is not None:
            return output_value, return_value

        if output_type is not None:
            return output_value

        if return_type is not None:
            return return_value

        return None

    async def subscribe(self, param_name: str, param_type: DecopMetaType = None) -> 'Subscription':
        """Creates a subscription to the value changes of a parameter.

        Args:
            param_name (str): The name of the parameter.
            param_type (Optional[DecopMetaType]): The expected type of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The monitoring line of the client connection is not available.')

        subscription = Subscription(self, param_name)

        if param_name in self._subscriptions:
            _, subscribers = self._subscriptions[param_name]
            subscribers.append(subscription)
        else:
            await self._connection.write_monitoring_line(f"(add '{param_name})\n")
            self._subscriptions[param_name] = (param_type, [subscription])

        return subscription

    async def unsubscribe(self, subscription: 'Subscription') -> None:
        """Cancels a subscription to the value changes of a parameter.

        Args:
            subscription (Subscription): The subscription to cancel.

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The monitoring line of the client connection is not available.')

        try:
            _, subscriptions = self._subscriptions[subscription.name]
            subscriptions.remove(subscription)

            if not subscriptions:
                await self._connection.write_monitoring_line(f"(remove '{subscription.name})\n")
                self._subscriptions.pop(subscription.name)
        except KeyError:
            pass

    @property
    def is_open(self) -> bool:
        """bool: True if the client connection is open, False otherwise."""
        return self._connection.is_open

    @property
    def command_line_available(self) -> bool:
        """bool: True if the command line is available, False otherwise."""
        return self._connection.command_line_available

    @property
    def monitoring_line_available(self) -> bool:
        """bool: True if the monitoring line is available, False otherwise."""
        return self._connection.monitoring_line_available

    @property
    def connection(self) -> Connection:
        """Connection: The connection of the client to the device."""
        return self._connection

    async def _monitoring_line_handler(self) -> None:
        """Continuously read from the monitoring line and distribute parameter changes to their subscribers."""
        try:
            while True:
                # Wait for a new message from the monitoring line
                message = await self._connection.read_monitoring_line()

                # Split the message into the timestamp, parameter name and value (which may be an error)
                timestamp, name, value = parse_monitoring_line(message)

                try:
                    # Get the expected type of the value and the list of subscriptions
                    value_type, subscribers = self._subscriptions[name]

                    if isinstance(value, DecopError):
                        for subscriber in subscribers:
                            await subscriber.update(timestamp, SubscriptionValue(value))
                    else:
                        try:
                            if value_type is None:
                                result = decode_value_inferred(value)
                            else:
                                result = decode_value(value, value_type)

                            for subscriber in subscribers:
                                await subscriber.update(timestamp, SubscriptionValue(result))

                        except DecopValueError as error:
                            for subscriber in subscribers:
                                await subscriber.update(timestamp, SubscriptionValue(error))
                except KeyError:
                    pass
        except ConnectionClosedError:
            pass


class Subscription:
    """A subscription to the value changes of a parameter.

    Attributes:
        client (Client): A client that is used to access the parameter.
        name (str): The name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client: Optional[Client] = client
        self._name = name
        self._queue: asyncio.Queue[Tuple[Timestamp, Optional[SubscriptionValue]]] = asyncio.Queue(maxsize=1)

    def __repr__(self) -> str:
        return f"<asyncio.Subscription name='{self._name}' qsize={self._queue.qsize()}>)"

    async def __aenter__(self) -> 'Subscription':
        return self

    async def __aexit__(self, *args) -> None:
        await self.cancel()

    def __await__(self):
        return self.next().__await__()  # pylint: disable=no-member

    def __aiter__(self) -> 'Subscription':
        return self

    async def __anext__(self) -> 'Tuple[Timestamp, DecopType]':
        """Returns the next value of the subscribed parameter.

        Returns:
            Tuple[Timestamp, DecopType]: A tuple containing a timestamp and the next available value of
                                         the subscribed parameter.

        Raises:
            StopAsyncIteration: If the subscription has been or already was canceled.
            DecopError: If the monitoring line returned an error message.

        """
        if self._client is None:
            raise StopAsyncIteration

        timestamp, value = await self._queue.get()

        if value is None:
            raise StopAsyncIteration

        return timestamp, value.get()

    async def next(self) -> 'Tuple[Timestamp, DecopType]':
        """ Returns the next value of the subscribed parameter.

            Returns:
                Tuple[Timestamp, DecopType]: A tuple containing a timestamp and the next available value of
                                             the subscribed parameter.

            Raises:
                DecopError: If the subscription has been cancelled or the monitoring line returned an error message.

        """
        if self._client is None:
            raise DecopError('The subscription has been cancelled.')

        # Wait for the next value from the monitoring line
        timestamp, value = await self._queue.get()

        if value is None:
            raise asyncio.CancelledError

        return timestamp, value.get()

    async def update(self, timestamp: Timestamp, value: SubscriptionValue) -> None:
        """Updates the subscription with a new value or error.

        Args:
            timestamp (Timestamp): The timestamp of the parameter update.
            value (SubscriptionValue): The new value of the parameter or an error.

        """
        await self._queue.put((timestamp, value))

    async def cancel(self) -> None:
        """Cancels the subscription for parameter updates."""
        if self._client is not None:
            await self._queue.put((datetime.now(), None))
            await self._client.unsubscribe(self)
        self._client = None

    @property
    def name(self) -> str:
        """str: The name of the parameter for this subscription."""
        return self._name

    @property
    def client(self) -> Optional[Client]:
        """Optional[Client]: The Client of this subscription (maybe None when it was canceled)."""
        return self._client


class DecopBoolean:
    """A read-only boolean parameter.

    Attributes:
        client (Client): A client that is used to access the parameter.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, await self._client.get(self._name, bool))
        return result

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, bool)


class MutableDecopBoolean:
    """A read/write DeCoP boolean parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, await self._client.get(self._name, bool))
        return result

    async def set(self, value: bool) -> int:
        """Updates the value of the parameter.

        Args:
            value (bool): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, bool), f"expected type 'bool' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, bool)


class SettableDecopBoolean:
    """A settable DeCoP boolean parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, await self._client.get(self._name, bool))
        return result

    async def get_set_value(self) -> bool:
        """Returns the current set-value of the parameter.

        Returns:
            bool: The current set-value of the parameter.

        """
        result = cast(bool, await self._client.get_set_value(self._name, bool))
        return result

    async def set(self, value: bool) -> int:
        """Updates the value of the parameter.

        Args:
            value (bool): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, bool), f"expected type 'bool' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, bool)


class DecopInteger:
    """A read-only DeCoP integer parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, await self._client.get(self._name, int))
        return result

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, int)


class MutableDecopInteger:
    """A read/write DeCoP integer parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, await self._client.get(self._name, int))
        return result

    async def set(self, value: int) -> int:
        """Updates the value of the parameter.

        Args:
            value (int): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, int), f"expected type 'int' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, int)


class SettableDecopInteger:
    """A settable DeCoP integer parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, await self._client.get(self._name, int))
        return result

    async def get_set_value(self) -> int:
        """Returns the current set-value of the parameter.

        Returns:
            int: The current set-value of the parameter.

        """
        result = cast(int, await self._client.get_set_value(self._name, int))
        return result

    async def set(self, value: int) -> int:
        """Updates the value of the parameter.

        Args:
            value (int): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, int), f"expected type 'int' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, int)


class DecopReal:
    """A read-only DeCoP floating point parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, await self._client.get(self._name, float))
        return result

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to updates of the parameter.

        """
        return await self._client.subscribe(self._name, float)


class MutableDecopReal:
    """A read/write DeCoP floating point parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, await self._client.get(self._name, float))
        return result

    async def set(self, value: Union[int, float]) -> int:
        """Updates the value of the parameter.

        Args:
            value Union[int, float]: The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, (int, float)), f"expected type 'int' or 'float' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, float(value))

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, float)


class SettableDecopReal:
    """A settable DeCoP floating point parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, await self._client.get(self._name, float))
        return result

    async def get_set_value(self) -> float:
        """Returns the current set-value of the parameter.

        Returns:
            float: The current set-value of the parameter.

        """
        result = cast(float, await self._client.get_set_value(self._name, float))
        return result

    async def set(self, value: Union[int, float]) -> int:
        """Updates the value of the parameter.

        Args:
            value Union[int, float]: The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, (int, float)), f"expected type 'int' or 'float' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, float(value))

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, float)


class DecopString:
    """A read-only DeCoP string parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, await self._client.get(self._name, str))
        return result

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, str)


class MutableDecopString:
    """A read/write DeCoP string parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, await self._client.get(self._name, str))
        return result

    async def set(self, value: str) -> int:
        """Updates the value of the parameter.

        Args:
            value (str): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, str), f"expected type 'str' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, str)


class SettableDecopString:
    """A settable DeCoP string parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, await self._client.get(self._name, str))
        return result

    async def get_set_value(self) -> str:
        """Returns the current set-value of the parameter.

        Returns:
            str: The current set-value of the parameter.

        """
        result = cast(str, await self._client.get_set_value(self._name, str))
        return result

    async def set(self, value: str) -> int:
        """Updates the value of the parameter.

        Args:
            value (str): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, str), f"expected type 'str' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, str)


class DecopBinary:
    """A read-only DeCoP binary parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, await self._client.get(self._name, bytes))
        return result

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, bytes)


class MutableDecopBinary:
    """A read/write DeCoP binary parameter.

    Attributes:
        client (Client): A DeCoP client that is used to access the parameter on a device
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

    """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, await self._client.get(self._name, bytes))
        return result

    async def set(self, value: Union[bytes, bytearray]) -> int:
        """Updates the value of the parameter.

        Args:
            value (Union[bytes, bytearray]): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, (bytes, bytearray)), \
            f"expected type 'bytes' or 'bytearray' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to updates of the parameter.

        """
        return await self._client.subscribe(self._name, bytes)


class SettableDecopBinary:
    """A settable DeCoP binary parameter.

     Attributes:
         client (Client): A DeCoP client that is used to access the parameter on a device
         name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime')

     """

    def __init__(self, client: Client, name: str) -> None:
        self._client = client
        self._name = name

    @property
    def name(self) -> str:
        """str: The fully qualified name of the parameter."""
        return self._name

    async def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, await self._client.get(self._name, bytes))
        return result

    async def get_set_value(self) -> bytes:
        """Returns the current set-value of the parameter.

        Returns:
            bytes: The current set-value of the parameter.

        """
        result = cast(bytes, await self._client.get_set_value(self._name, bytes))
        return result

    async def set(self, value: Union[bytes, bytearray]) -> int:
        """Updates the value of the parameter.

        Args:
            value (Union[bytes, bytearray]): The new value of the parameter.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.

        """
        assert isinstance(value, (bytes, bytearray)), \
            f"expected type 'bytes' or 'bytearray' for 'value', got '{type(value)}'"
        return await self._client.set(self._name, value)

    async def subscribe(self) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return await self._client.subscribe(self._name, bytes)
