from time import sleep

from toptica.lasersdk.client import Client, NetworkConnection
from toptica.lasersdk.client import UserLevel, Subscription, Timestamp, SubscriptionValue


# The following string is used to define the connection to the device. It can be either
# an IP address, a serial number or system label (when it is in the same subnet),
# or a DNS entry (e.g. 'dlcpro.example.com').
DLCPRO_CONNECTION = '192.168.1.29'


# This will create a new Client and connect to the device via Ethernet. The with-statement
# will automatically call Client.open() and Client.close() at the appropriate times (without
# it these methods have to be called explicitly).
with Client(NetworkConnection(DLCPRO_CONNECTION)) as client:

    #
    # --- Client.get() ---

    # Client.get() allows to query the current value of a parameter. The type of the parameter
    # value is inferred from the response sent by the device.
    print("=== Connected Device ===")
    print("This is a {} with serial number {}.\n".format(
        client.get('system-type'), client.get('serial-number')))

    # Client.get() has an optional second parameter that defines the expected type of the
    # parameter value.
    #
    # The following line would raise a DecopValueError exception because the 'uptime-txt'
    # parameter is a string (therefore would require 'str' as second parameter).
    #
    # print(client.get('uptime-txt', int))

    #
    # --- Client.set() ---

    # Save the current value of the display brightness.
    display_brightness = client.get('display:brightness')
    print("=== Display Brightness ===")
    print('Display Brightness - before:', display_brightness)

    # Client.set() allows to change the value of every writable parameter.
    client.set('display:brightness', 80)
    print('Display Brightness - after: ', client.get('display:brightness'), '\n')

    # Restore the original display brightness.
    client.set('display:brightness', display_brightness)

    #
    # --- Client.change_ul() ---

    # Client.change_ul() allows to change the userlevel of the connection.
    print("=== Userlevel ===")
    print('Userlevel - before:', UserLevel(client.get('ul')))

    # Change the userlevel to "MAINTENANCE".
    client.change_ul(UserLevel.MAINTENANCE, 'CAUTION')
    print('Userlevel - after: ', UserLevel(client.get('ul')), '\n')

    # Change the userlevel back to "NORMAL" (this usually doesn't require a password).
    client.change_ul(UserLevel.NORMAL, '')

    #
    # --- Client.exec() ---

    # Client.exec() allows the execution of commands. The optional 'output_type=str'
    # specifies that the command has additional output that should be returned as a
    # string (the system messages in this case).
    system_messages = client.exec('system-messages:show-all', output_type=str)
    print("=== System Messages ===")
    print(system_messages)

    #
    # --- Client.subscribe() ---

    # This callback is used to print value changes of the parameter 'uptime-txt'.
    def uptime_txt_changed(subscription: Subscription, timestamp: Timestamp, value: SubscriptionValue):
        print("{}: '{}' = '{}'".format(timestamp.time(), subscription.name, value.get()))

    # Client.subscribe() allows adding callbacks for value changes of parameters.
    # Subscribing to value changes requires to either regularly call Client.poll()
    # (which will process all currently queued up callbacks) or Client.run() (which
    # will continuously process callbacks and block until Client.stop() is called).
    print("=== Uptime Subscription ===")
    client.subscribe('uptime-txt', uptime_txt_changed)

    for _ in range(3):
        sleep(1)  # Sleep for one second to simulate some work being done
        client.poll()