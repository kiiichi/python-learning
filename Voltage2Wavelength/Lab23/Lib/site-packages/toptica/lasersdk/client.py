import asyncio
import time
import threading

from asyncio import AbstractEventLoop
from concurrent.futures import Future
from datetime import datetime

from queue import Queue
from queue import Empty

from typing import cast, Coroutine, Any
from typing import Dict

from typing import Callable
from typing import List
from typing import Optional
from typing import Tuple
from typing import Union

import toptica.lasersdk.asyncio.client as async_client

from .decop import UserLevel

from .decop import DecopError
from .decop import DecopMetaType
from .decop import DecopStreamMetaType
from .decop import DecopStreamType
from .decop import DecopType
from .decop import DecopValueError
from .decop import SubscriptionValue
from .decop import Timestamp

from .asyncio.connection import Connection
from .asyncio.connection import NetworkConnection
from .asyncio.connection import SerialConnection

from .asyncio.connection import DeviceNotFoundError
from .asyncio.connection import UnavailableError

__all__ = ['Client', 'Connection', 'UserLevel', 'DecopType', 'SubscriptionValue',
           'NetworkConnection', 'SerialConnection',
           'DecopError', 'DecopValueError', 'DeviceNotFoundError', 'DeviceTimeoutError',
           'DecopBinary', 'MutableDecopBinary', 'SettableDecopBinary',
           'DecopBoolean', 'MutableDecopBoolean', 'SettableDecopBoolean',
           'DecopInteger', 'MutableDecopInteger', 'SettableDecopInteger',
           'DecopReal', 'MutableDecopReal', 'SettableDecopReal',
           'DecopString', 'MutableDecopString', 'SettableDecopString',
           'Subscription', 'Timestamp', 'SubscriptionValue', 'DecopCallback']


DecopCallback = Callable[['Subscription', Timestamp, SubscriptionValue], None]


class DeviceTimeoutError(DecopError):
    """An exception that is raised when connecting to a device has failed."""


class Client:
    """A client for devices that support the Device Control Protocol (DeCoP).

    Attributes:
        connection (Connection): A connection that is used to communicate with the device.

    """

    def __init__(self, connection: Connection) -> None:
        self._connection = connection
        self._thread = threading.Thread(target=self._event_loop_thread, daemon=True)
        self._init_barrier = threading.Barrier(2)
        self._async_client = async_client.Client(connection)
        self._loop: Optional[AbstractEventLoop] = None
        self._is_running = False
        self._async_subscriptions: Dict[str, Tuple[async_client.Subscription, Future]] = {}
        self._subscriptions: Dict[str, Tuple[Optional[DecopMetaType], List[Subscription]]] = {}
        self._monitoring_line_queue: Queue[Tuple[Timestamp, str, SubscriptionValue]] = Queue()

    def __enter__(self) -> 'Client':
        self.open()
        return self

    def __exit__(self, *args):
        self.close()

    def open(self) -> None:
        """Opens a connection to the device.

        Raises:
            DeviceNotFoundError: If opening the connection to the device has failed.

        """
        if self.is_open:
            return

        # Create a barrier for this and the event loop thread to wait on
        self._init_barrier = threading.Barrier(2)

        # Start the event loop thread and wait for its initialization
        self._thread = threading.Thread(target=self._event_loop_thread, daemon=True)
        self._thread.start()

        self._init_barrier.wait()

        # Open and wait for the asynchronous client
        try:
            if self._loop is not None:
                fut = asyncio.run_coroutine_threadsafe(self._async_client.open(), self._loop)
                fut.result()
        except BaseException as error:
            self.close()
            raise error

    def close(self) -> None:
        """Closes the connection to the device.

        Raises:
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            return

        subscriptions: List[Subscription] = []

        for _, value in self._subscriptions.values():
            subscriptions += value

        for subscription in subscriptions:
            subscription.cancel()

        try:
            # Close the asynchronous client
            self._async_run(self._async_client.close())
        finally:
            # Wrap the stop() in a coroutine
            async def _async_stop():
                self._loop.stop()

            # Post a coroutine that will stop the event loop
            asyncio.run_coroutine_threadsafe(_async_stop(), self._loop)

            # Wait for the event loop thread to exit
            self._thread.join()

    def change_ul(self, ul: UserLevel, password: Optional[str] = None) -> UserLevel:
        """Changes the user level of the client connection.

        Args:
            ul (UserLevel): The requested user level.
            password (Optional[str]): The password for the requested user level.

        Returns:
            UserLevel: The new user level or the previous one if the password was incorrect.

        Raises:
            UnavailableError: If the connection is closed.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        return cast(UserLevel, self._async_run(self._async_client.change_ul(ul, password)))

    def run(self, timeout: float = None) -> None:
        """Invokes all scheduled callbacks until a timeout occurres.

        Args:
            timeout (Optional[float]): An optional timeout (in seconds) after this function will return. Without a
                                       timeout this function will run indefinitely (or until stop() is called). When
                                       timeout=0 this function behaves like poll().

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.

        """
        if self._loop is None:
            raise UnavailableError('Client connection to the device is closed')

        if not self._connection.monitoring_line_available:
            raise UnavailableError('Client connection does not have a monitoring line')

        # Only handle the values that are currently in the queue when timeout == 0
        if timeout == 0:
            try:
                for _ in range(self._monitoring_line_queue.qsize()):
                    timestamp, name, value = self._monitoring_line_queue.get_nowait()
                    self._update_subscriptions(timestamp, name, value)
            except Empty:
                pass
            return

        if timeout is None:
            _t = 0.1
        else:
            _t = min(timeout, 0.1)

        start_time = time.monotonic()
        self._is_running = True

        while self._is_running:
            try:
                # Wait for new parameter update to arrive
                timestamp, name, value = self._monitoring_line_queue.get(block=True, timeout=_t)

                # Update all subscriptions with the new value
                self._update_subscriptions(timestamp, name, value)

            except Empty:
                if timeout is not None:
                    now = time.monotonic()
                    if now < start_time + timeout:
                        _t = min(start_time + timeout - now, 0.1)
                    else:
                        return

    def stop(self) -> None:
        """Stops the event loop for the monitoring line."""
        self._is_running = False

    def poll(self) -> None:
        """Invokes the next queued callback.

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.

        """
        self.run(timeout=0)

    def get(self, param_name: str, *param_types: DecopMetaType) -> DecopType:
        """Returns the current value of a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_types (DecopMetaType): Zero or more types of the DeCoP parameter.

        Returns:
            DecopType: The current value of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopValueError: If the provided types don't match the result from the device.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        return cast(DecopType, self._async_run(self._async_client.get(param_name, *param_types)))

    def get_set_value(self, param_name: str, *param_types: DecopMetaType) -> DecopType:
        """Returns the current 'set value' of a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_types (DecopMetaType): Zero or more types of the DeCoP parameter.

        Returns:
            DecopType: The 'set value' of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopValueError: If the provided types don't match the result from the device.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        return cast(DecopType, self._async_run(self._async_client.get_set_value(param_name, *param_types)))

    def set(self, param_name: str, *param_values: DecopType) -> int:
        """Sets a new value for a DeCoP parameter.

        Args:
            param_name (str): The name of the DeCoP parameter (e.g. 'laser1:enabled').
            param_values (DecopType): One or more parameter values.

        Returns:
            int: Zero if successful or a positive integer indicating a warning.

        Raises:
            UnavailableError: If the connection is closed or the command line is not available.
            DecopError: If the device returned an error when setting the new value.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        return cast(int, self._async_run(self._async_client.set(param_name, *param_values)))

    def exec(self, name: str, *args, input_stream: DecopStreamType = None,
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
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The command line of the client connection is not available.')

        return cast(Optional[DecopType], self._async_run(
            self._async_client.exec(name, *args, input_stream=input_stream, output_type=output_type,
                                    return_type=return_type)))

    def subscribe(self, param_name: str, callback: DecopCallback, param_type: DecopMetaType = None) -> 'Subscription':
        """Creates a subscription to the value changes of a parameter.

        Args:
            param_name (str): The name of the parameter.
            callback (DecopCallback): The callback that will be invoked on parameter updates.
            param_type (Optional[DecopMetaType]): The expected type of the parameter.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        async def _await_next_value(sub: async_client.Subscription):
            while True:
                value: Union[DecopType, DecopError]
                try:
                    timestamp, value = await sub.next()
                except DecopError as exc:
                    timestamp, value = datetime.now(), exc

                if self._loop is not None:
                    item = (timestamp, sub.name, SubscriptionValue(value))
                    await self._loop.run_in_executor(None, lambda: self._monitoring_line_queue.put(item))

        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.monitoring_line_available:
            raise UnavailableError('The monitoring line of the client connection is not available.')

        if param_name not in self._async_subscriptions:
            # Subscribe the parameter in the async client if this is the first subscription
            async_subscription = self._async_run(self._async_client.subscribe(param_name, param_type))

            # Create a task that will await the async subscription updates
            future = asyncio.run_coroutine_threadsafe(_await_next_value(async_subscription), self._loop)
            self._async_subscriptions[param_name] = (async_subscription, future)

        subscription = Subscription(self, param_name, callback)

        if param_name in self._subscriptions:
            _, subscriptions = self._subscriptions[param_name]
            subscriptions.append(subscription)
        else:
            self._subscriptions[param_name] = (param_type, [subscription])

        return subscription

    def unsubscribe(self, subscription: 'Subscription') -> None:
        """Cancels a subscription to the value changes of a parameter.

        Args:
            subscription (Subscription): The subscription to cancel.

        Raises:
            UnavailableError: If the connection is closed or the monitoring line is not available.
            DeviceTimeoutError: If the operation did not complete in time.

        """
        if not self.is_open:
            raise UnavailableError('The client connection to the device is closed.')

        if not self.command_line_available:
            raise UnavailableError('The monitoring line of the client connection is not available.')

        try:
            _, subscriptions = self._subscriptions[subscription.name]
            subscriptions.remove(subscription)

            if not subscriptions:
                # Cancel the async subscription if this is the last subscription
                async_subscription, future = self._async_subscriptions[subscription.name]

                # Cancel the task that awaits parameter updates
                future.cancel()
                self._async_run(self._async_client.unsubscribe(async_subscription))

                self._async_subscriptions.pop(subscription.name)
                self._subscriptions.pop(subscription.name)

        except KeyError:
            pass

    @property
    def is_open(self) -> bool:
        """bool: True if the client connection is open, False otherwise."""
        return self._loop is not None

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

    def _event_loop_thread(self) -> None:
        """Thread function that runs its own asyncio event loop."""

        # Create a new event loop for this thread
        self._loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self._loop)

        # Signal that 'self._loop' is valid
        self._init_barrier.wait()

        # Run the event loop until loop.stop() is posted
        self._loop.run_forever()
        self._loop.close()

        self._loop = None

    def _async_run(self, coro: Coroutine) -> Any:
        """Runs a coroutine in the event loop thread.

        Args:
            coro (Coroutine): The coroutine that should be run in the event loop thread.

        Returns:
            Any: The return value of the coroutine.

        """
        async def _run_with_timeout(_coro: Coroutine):
            try:
                return await asyncio.wait_for(_coro, self._connection.timeout)
            except asyncio.TimeoutError:
                raise DeviceTimeoutError from None

        if self._loop is not None:
            future = asyncio.run_coroutine_threadsafe(_run_with_timeout(coro), self._loop)
            return future.result()

    def _update_subscriptions(self, timestamp: Timestamp, name: str, value: SubscriptionValue) -> None:
        """Invokes all callbacks of a subscribed parameter with the new value.

        Args:
            timestamp(Timestamp): The timestamp of the new value.
            name (str): The name of the parameter.
            value (SubscriptionValue): The new value of the parameter or an exception.

        """
        try:
            for subscription in self._subscriptions[name][1]:
                subscription.update(timestamp, value)
        except KeyError:
            pass  # May have already been unsubscribed


class Subscription:
    """A subscription to the value changes of a parameter.

    Attributes:
        client (Client): A client that is used to access the parameter.
        name (str): The fully qualified name of the parameter (e.g. 'laser1:amp:ontime').
        callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

    """

    def __init__(self, client: Client, name: str, callback: DecopCallback) -> None:
        self._client: Optional[Client] = client
        self._name = name
        self._callback: Optional[DecopCallback] = callback

    def __repr__(self) -> str:
        callback_name = self._callback.__name__ if self._callback is not None else 'None'
        return f"<Subscription name='{self._name}' callback={callback_name}>"

    def __enter__(self):
        return self

    def __exit__(self, *args):
        if self._client is not None:
            self.cancel()

    def update(self, timestamp: Timestamp, value: SubscriptionValue) -> None:
        """Invokes the callback with an updated parameter value.

        Args:
            timestamp (Timestamp): The timestamp of the parameter update.
            value (SubscriptionValue): The new value of the parameter or an error.

        """
        if self._callback is not None:
            self._callback(self, timestamp, value)

    def cancel(self) -> None:
        """Cancels the subscription for parameter updates."""
        if self._client is not None:
            self._client.unsubscribe(self)
        self._client = self._callback = None

    @property
    def name(self) -> str:
        """str: The name of the parameter for this subscription."""
        return self._name

    @property
    def client(self) -> Optional[Client]:
        """Optional[Client]: The Client of this subscription (maybe None when it was canceled)."""
        return self._client


class DecopBoolean:
    """A read-only DeCoP boolean parameter.

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

    def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, self._client.get(self._name, bool))
        return result

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bool)


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

    def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, self._client.get(self._name, bool))
        return result

    def set(self, value: bool) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bool)


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

    def get(self) -> bool:
        """Returns the current value of the parameter.

        Returns:
            bool: The current value of the parameter.

        """
        result = cast(bool, self._client.get(self._name, bool))
        return result

    def get_set_value(self) -> bool:
        """Returns the current set-value of the parameter.

        Returns:
            bool: The current set-value of the parameter.

        """
        result = cast(bool, self._client.get_set_value(self._name, bool))
        return result

    def set(self, value: bool) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bool)


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

    def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, self._client.get(self._name, int))
        return result

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, int)


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

    def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, self._client.get(self._name, int))
        return result

    def set(self, value: int) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, int)


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

    def get(self) -> int:
        """Returns the current value of the parameter.

        Returns:
            int: The current value of the parameter.

        """
        result = cast(int, self._client.get(self._name, int))
        return result

    def get_set_value(self) -> int:
        """Returns the current set-value of the parameter.

        Returns:
            int: The current set-value of the parameter.

        """
        result = cast(int, self._client.get_set_value(self._name, int))
        return result

    def set(self, value: int) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, int)


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

    def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, self._client.get(self._name, float))
        return result

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, float)


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

    def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, self._client.get(self._name, float))
        return result

    def set(self, value: Union[int, float]) -> int:
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
        return self._client.set(self._name, float(value))

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, float)


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

    def get(self) -> float:
        """Returns the current value of the parameter.

        Returns:
            float: The current value of the parameter.

        """
        result = cast(float, self._client.get(self._name, float))
        return result

    def get_set_value(self) -> float:
        """Returns the current set-value of the parameter.

        Returns:
            float: The current set-value of the parameter.

        """
        result = cast(float, self._client.get_set_value(self._name, float))
        return result

    def set(self, value: Union[int, float]) -> int:
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
        return self._client.set(self._name, float(value))

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, float)


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

    def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, self._client.get(self._name, str))
        return result

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, str)


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

    def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, self._client.get(self._name, str))
        return result

    def set(self, value: str) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, str)


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

    def get(self) -> str:
        """Returns the current value of the parameter.

        Returns:
            str: The current value of the parameter.

        """
        result = cast(str, self._client.get(self._name, str))
        return result

    def get_set_value(self) -> str:
        """Returns the current set-value of the parameter.

        Returns:
            str: The current set-value of the parameter.

        """
        result = cast(str, self._client.get_set_value(self._name, str))
        return result

    def set(self, value: str) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, str)


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

    def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, self._client.get(self._name, bytes))
        return result

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bytes)


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

    def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, self._client.get(self._name, bytes))
        return result

    def set(self, value: Union[bytes, bytearray]) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bytes)


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

    def get(self) -> bytes:
        """Returns the current value of the parameter.

        Returns:
            bytes: The current value of the parameter.

        """
        result = cast(bytes, self._client.get(self._name, bytes))
        return result

    def get_set_value(self) -> bytes:
        """Returns the current set-value of the parameter.

        Returns:
            bytes: The current set-value of the parameter.

        """
        result = cast(bytes, self._client.get_set_value(self._name, bytes))
        return result

    def set(self, value: Union[bytes, bytearray]) -> int:
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
        return self._client.set(self._name, value)

    def subscribe(self, callback: DecopCallback) -> 'Subscription':
        """Creates a subscription to the value changes of the parameter.

        Args:
            callback (DecopCallback): A callback that will be invoked when the value of the parameter has changed.

        Returns:
            Subscription: A subscription to the value changes of the parameter.

        """
        return self._client.subscribe(self._name, callback, bytes)
