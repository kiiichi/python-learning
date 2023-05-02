# Generated from 'v1_0_8.xml' on 2023-03-13 11:43:31.061452

from typing import Tuple
from typing import Optional

from toptica.lasersdk.asyncio.client import UserLevel
from toptica.lasersdk.asyncio.client import Client

from toptica.lasersdk.asyncio.client import DecopError
from toptica.lasersdk.asyncio.client import DeviceNotFoundError

from toptica.lasersdk.asyncio.client import DecopBoolean
from toptica.lasersdk.asyncio.client import DecopInteger
from toptica.lasersdk.asyncio.client import DecopReal
from toptica.lasersdk.asyncio.client import DecopString
from toptica.lasersdk.asyncio.client import DecopBinary

from toptica.lasersdk.asyncio.client import MutableDecopBoolean
from toptica.lasersdk.asyncio.client import MutableDecopInteger
from toptica.lasersdk.asyncio.client import MutableDecopReal
from toptica.lasersdk.asyncio.client import MutableDecopString
from toptica.lasersdk.asyncio.client import MutableDecopBinary

from toptica.lasersdk.asyncio.client import SettableDecopBoolean
from toptica.lasersdk.asyncio.client import SettableDecopInteger
from toptica.lasersdk.asyncio.client import SettableDecopReal
from toptica.lasersdk.asyncio.client import SettableDecopString
from toptica.lasersdk.asyncio.client import SettableDecopBinary

from toptica.lasersdk.asyncio.client import Subscription
from toptica.lasersdk.asyncio.client import Timestamp
from toptica.lasersdk.asyncio.client import SubscriptionValue

from toptica.lasersdk.asyncio.client import Connection
from toptica.lasersdk.asyncio.client import SerialConnection

import toptica.lasersdk.asyncio.client


class NetworkConnection(toptica.lasersdk.asyncio.client.NetworkConnection):
    def __init__(self, host: str, command_line_port: int = 50000, monitoring_line_port: int = 0, timeout: int = 5) -> None:
        super().__init__(host, command_line_port, monitoring_line_port, timeout)


class Laser:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._label = DecopString(client, name + ':label')
        self._type = DecopString(client, name + ':type')
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._cw = MutableDecopBoolean(client, name + ':cw')
        self._ready = DecopBoolean(client, name + ':ready')
        self._fault = DecopBoolean(client, name + ':fault')
        self._clip = DecopBoolean(client, name + ':clip')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._level = MutableDecopReal(client, name + ':level')
        self._raw_level = MutableDecopInteger(client, name + ':raw-level')
        self._rescue_level = MutableDecopReal(client, name + ':rescue-level')
        self._analog_mode = MutableDecopBoolean(client, name + ':analog-mode')
        self._use_ttl = MutableDecopBoolean(client, name + ':use-ttl')
        self._fine = Fine(client, name + ':fine')
        self._delay = MutableDecopInteger(client, name + ':delay')
        self._entime = DecopInteger(client, name + ':entime')
        self._entime_txt = DecopString(client, name + ':entime-txt')
        self._ontime = DecopInteger(client, name + ':ontime')
        self._ontime_txt = DecopString(client, name + ':ontime-txt')
        self._internal100 = MutableDecopReal(client, name + ':internal100')
        self._diode = Diode(client, name + ':diode')
        self._shg = Shg(client, name + ':shg')
        self._beam = Beam(client, name + ':beam')

    @property
    def label(self) -> 'DecopString':
        return self._label

    @property
    def type(self) -> 'DecopString':
        return self._type

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def cw(self) -> 'MutableDecopBoolean':
        return self._cw

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    @property
    def clip(self) -> 'DecopBoolean':
        return self._clip

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def level(self) -> 'MutableDecopReal':
        return self._level

    @property
    def raw_level(self) -> 'MutableDecopInteger':
        return self._raw_level

    @property
    def rescue_level(self) -> 'MutableDecopReal':
        return self._rescue_level

    @property
    def analog_mode(self) -> 'MutableDecopBoolean':
        return self._analog_mode

    @property
    def use_ttl(self) -> 'MutableDecopBoolean':
        return self._use_ttl

    @property
    def fine(self) -> 'Fine':
        return self._fine

    @property
    def delay(self) -> 'MutableDecopInteger':
        return self._delay

    @property
    def entime(self) -> 'DecopInteger':
        return self._entime

    @property
    def entime_txt(self) -> 'DecopString':
        return self._entime_txt

    @property
    def ontime(self) -> 'DecopInteger':
        return self._ontime

    @property
    def ontime_txt(self) -> 'DecopString':
        return self._ontime_txt

    @property
    def internal100(self) -> 'MutableDecopReal':
        return self._internal100

    @property
    def diode(self) -> 'Diode':
        return self._diode

    @property
    def shg(self) -> 'Shg':
        return self._shg

    @property
    def beam(self) -> 'Beam':
        return self._beam

    async def reset_clip(self) -> None:
        await self.__client.exec(self.__name + ':reset-clip', input_stream=None, output_type=None, return_type=None)

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    async def gen_lookup(self) -> None:
        await self.__client.exec(self.__name + ':gen-lookup', input_stream=None, output_type=None, return_type=None)

    async def disp_lookup(self) -> None:
        await self.__client.exec(self.__name + ':disp-lookup', input_stream=None, output_type=None, return_type=None)

    async def store_lookup(self) -> None:
        await self.__client.exec(self.__name + ':store-lookup', input_stream=None, output_type=None, return_type=None)

    async def load_lookup(self) -> None:
        await self.__client.exec(self.__name + ':load-lookup', input_stream=None, output_type=None, return_type=None)

    async def clear_lookup(self) -> None:
        await self.__client.exec(self.__name + ':clear-lookup', input_stream=None, output_type=None, return_type=None)

    async def check_lookup(self) -> float:
        return await self.__client.exec(self.__name + ':check-lookup', input_stream=None, output_type=None, return_type=float)

    async def set_internal100(self) -> None:
        await self.__client.exec(self.__name + ':set-internal100', input_stream=None, output_type=None, return_type=None)

    async def set_external100(self, power: float) -> None:
        assert isinstance(power, float), f"expected type 'float' for parameter 'power', got '{type(power)}'"
        await self.__client.exec(self.__name + ':set-external100', power, input_stream=None, output_type=None, return_type=None)

    async def recalibrate(self) -> None:
        await self.__client.exec(self.__name + ':recalibrate', input_stream=None, output_type=None, return_type=None)

    async def store_calibration(self) -> None:
        await self.__client.exec(self.__name + ':store-calibration', input_stream=None, output_type=None, return_type=None)

    async def restore_settings(self) -> None:
        await self.__client.exec(self.__name + ':restore-settings', input_stream=None, output_type=None, return_type=None)


class Fine:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._a = MutableDecopReal(client, name + ':a')
        self._b = MutableDecopReal(client, name + ':b')

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def a(self) -> 'MutableDecopReal':
        return self._a

    @property
    def b(self) -> 'MutableDecopReal':
        return self._b


class Diode:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._diode_type = MutableDecopString(client, name + ':diode-type')
        self._biascur = MutableDecopReal(client, name + ':biascur')
        self._curampl = MutableDecopReal(client, name + ':curampl')
        self._cursetfactor = MutableDecopInteger(client, name + ':cursetfactor')
        self._cur = DecopReal(client, name + ':cur')
        self._volt = DecopReal(client, name + ':volt')
        self._maxcur = DecopReal(client, name + ':maxcur')
        self._compcur = MutableDecopReal(client, name + ':compcur')
        self._emisel = DecopInteger(client, name + ':emisel')
        self._chsel = DecopInteger(client, name + ':chsel')
        self._ldcr = DecopInteger(client, name + ':ldcr')
        self._hfmp = DecopInteger(client, name + ':hfmp')
        self._hfmf = DecopInteger(client, name + ':hfmf')
        self._modamp = DecopInteger(client, name + ':modamp')
        self._sm_ch2 = DecopBoolean(client, name + ':sm-ch2')
        self._sm_ch5 = DecopBoolean(client, name + ':sm-ch5')
        self._oscenable = MutableDecopBoolean(client, name + ':oscenable')
        self._r_disable = MutableDecopBoolean(client, name + ':r-disable')
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._comparator = DecopBoolean(client, name + ':comparator')

    @property
    def diode_type(self) -> 'MutableDecopString':
        return self._diode_type

    @property
    def biascur(self) -> 'MutableDecopReal':
        return self._biascur

    @property
    def curampl(self) -> 'MutableDecopReal':
        return self._curampl

    @property
    def cursetfactor(self) -> 'MutableDecopInteger':
        return self._cursetfactor

    @property
    def cur(self) -> 'DecopReal':
        return self._cur

    @property
    def volt(self) -> 'DecopReal':
        return self._volt

    @property
    def maxcur(self) -> 'DecopReal':
        return self._maxcur

    @property
    def compcur(self) -> 'MutableDecopReal':
        return self._compcur

    @property
    def emisel(self) -> 'DecopInteger':
        return self._emisel

    @property
    def chsel(self) -> 'DecopInteger':
        return self._chsel

    @property
    def ldcr(self) -> 'DecopInteger':
        return self._ldcr

    @property
    def hfmp(self) -> 'DecopInteger':
        return self._hfmp

    @property
    def hfmf(self) -> 'DecopInteger':
        return self._hfmf

    @property
    def modamp(self) -> 'DecopInteger':
        return self._modamp

    @property
    def sm_ch2(self) -> 'DecopBoolean':
        return self._sm_ch2

    @property
    def sm_ch5(self) -> 'DecopBoolean':
        return self._sm_ch5

    @property
    def oscenable(self) -> 'MutableDecopBoolean':
        return self._oscenable

    @property
    def r_disable(self) -> 'MutableDecopBoolean':
        return self._r_disable

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def comparator(self) -> 'DecopBoolean':
        return self._comparator


class Shg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp = SettableDecopReal(client, name + ':temp')
        self._opt_step = MutableDecopReal(client, name + ':opt-step')
        self._opt_delay = MutableDecopInteger(client, name + ':opt-delay')
        self._opt_timeout = MutableDecopInteger(client, name + ':opt-timeout')
        self._opt_tolerance = MutableDecopReal(client, name + ':opt-tolerance')
        self._opt_level = MutableDecopReal(client, name + ':opt-level')
        self._opt_keep_level = MutableDecopBoolean(client, name + ':opt-keep-level')

    @property
    def temp(self) -> 'SettableDecopReal':
        return self._temp

    @property
    def opt_step(self) -> 'MutableDecopReal':
        return self._opt_step

    @property
    def opt_delay(self) -> 'MutableDecopInteger':
        return self._opt_delay

    @property
    def opt_timeout(self) -> 'MutableDecopInteger':
        return self._opt_timeout

    @property
    def opt_tolerance(self) -> 'MutableDecopReal':
        return self._opt_tolerance

    @property
    def opt_level(self) -> 'MutableDecopReal':
        return self._opt_level

    @property
    def opt_keep_level(self) -> 'MutableDecopBoolean':
        return self._opt_keep_level

    async def optimize(self) -> None:
        await self.__client.exec(self.__name + ':optimize', input_stream=None, output_type=None, return_type=None)

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Beam:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._drive_a = Elliptec(client, name + ':drive-a')
        self._drive_b = Elliptec(client, name + ':drive-b')

    @property
    def drive_a(self) -> 'Elliptec':
        return self._drive_a

    @property
    def drive_b(self) -> 'Elliptec':
        return self._drive_b

    async def shiftpolar(self, radial: int, tangential: int) -> None:
        assert isinstance(radial, int), f"expected type 'int' for parameter 'radial', got '{type(radial)}'"
        assert isinstance(tangential, int), f"expected type 'int' for parameter 'tangential', got '{type(tangential)}'"
        await self.__client.exec(self.__name + ':shiftpolar', radial, tangential, input_stream=None, output_type=None, return_type=None)

    async def shift(self, step_a: int, step_b: int) -> None:
        assert isinstance(step_a, int), f"expected type 'int' for parameter 'step_a', got '{type(step_a)}'"
        assert isinstance(step_b, int), f"expected type 'int' for parameter 'step_b', got '{type(step_b)}'"
        await self.__client.exec(self.__name + ':shift', step_a, step_b, input_stream=None, output_type=None, return_type=None)

    async def optimize(self) -> int:
        return await self.__client.exec(self.__name + ':optimize', input_stream=None, output_type=None, return_type=int)

    async def rescue(self) -> int:
        return await self.__client.exec(self.__name + ':rescue', input_stream=None, output_type=None, return_type=int)

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Elliptec:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._fwdfreq = MutableDecopInteger(client, name + ':fwdfreq')
        self._backfreq = MutableDecopInteger(client, name + ':backfreq')
        self._fwdnorm = MutableDecopInteger(client, name + ':fwdnorm')
        self._backnorm = MutableDecopInteger(client, name + ':backnorm')
        self._frequency = MutableDecopInteger(client, name + ':frequency')
        self._moves = MutableDecopInteger(client, name + ':moves')
        self._travel = MutableDecopReal(client, name + ':travel')
        self._step = MutableDecopInteger(client, name + ':step')

    @property
    def fwdfreq(self) -> 'MutableDecopInteger':
        return self._fwdfreq

    @property
    def backfreq(self) -> 'MutableDecopInteger':
        return self._backfreq

    @property
    def fwdnorm(self) -> 'MutableDecopInteger':
        return self._fwdnorm

    @property
    def backnorm(self) -> 'MutableDecopInteger':
        return self._backnorm

    @property
    def frequency(self) -> 'MutableDecopInteger':
        return self._frequency

    @property
    def moves(self) -> 'MutableDecopInteger':
        return self._moves

    @property
    def travel(self) -> 'MutableDecopReal':
        return self._travel

    @property
    def step(self) -> 'MutableDecopInteger':
        return self._step

    async def findfreqs(self) -> str:
        return await self.__client.exec(self.__name + ':findfreqs', input_stream=None, output_type=str, return_type=None)

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    async def move(self, time: int) -> None:
        assert isinstance(time, int), f"expected type 'int' for parameter 'time', got '{type(time)}'"
        await self.__client.exec(self.__name + ':move', time, input_stream=None, output_type=None, return_type=None)

    async def fwd(self) -> None:
        await self.__client.exec(self.__name + ':fwd', input_stream=None, output_type=None, return_type=None)

    async def back(self) -> None:
        await self.__client.exec(self.__name + ':back', input_stream=None, output_type=None, return_type=None)

    async def run(self, frequency: int) -> int:
        assert isinstance(frequency, int), f"expected type 'int' for parameter 'frequency', got '{type(frequency)}'"
        return await self.__client.exec(self.__name + ':run', frequency, input_stream=None, output_type=None, return_type=int)

    async def stop(self) -> None:
        await self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)


class AllLasers:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._enable_led = DecopBoolean(client, name + ':enable-led')
        self._cw = MutableDecopBoolean(client, name + ':cw')
        self._analog_mode = MutableDecopBoolean(client, name + ':analog-mode')
        self._use_ttl = MutableDecopBoolean(client, name + ':use-ttl')
        self._ttl_active_high = MutableDecopBoolean(client, name + ':ttl-active-high')
        self._ttl_master_mode = MutableDecopBoolean(client, name + ':ttl-master-mode')
        self._digital_over_analog = MutableDecopBoolean(client, name + ':digital-over-analog')
        self._ready = DecopBoolean(client, name + ':ready')
        self._fault = DecopBoolean(client, name + ':fault')

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def enable_led(self) -> 'DecopBoolean':
        return self._enable_led

    @property
    def cw(self) -> 'MutableDecopBoolean':
        return self._cw

    @property
    def analog_mode(self) -> 'MutableDecopBoolean':
        return self._analog_mode

    @property
    def use_ttl(self) -> 'MutableDecopBoolean':
        return self._use_ttl

    @property
    def ttl_active_high(self) -> 'MutableDecopBoolean':
        return self._ttl_active_high

    @property
    def ttl_master_mode(self) -> 'MutableDecopBoolean':
        return self._ttl_master_mode

    @property
    def digital_over_analog(self) -> 'MutableDecopBoolean':
        return self._digital_over_analog

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    async def reset_clip(self) -> None:
        await self.__client.exec(self.__name + ':reset-clip', input_stream=None, output_type=None, return_type=None)

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    async def restore_settings(self) -> None:
        await self.__client.exec(self.__name + ':restore-settings', input_stream=None, output_type=None, return_type=None)


class Tec:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._fault = DecopBoolean(client, name + ':fault')
        self._temp = SettableDecopReal(client, name + ':temp')
        self._ki = MutableDecopInteger(client, name + ':ki')
        self._kp = MutableDecopInteger(client, name + ':kp')
        self._pwm = MutableDecopInteger(client, name + ':pwm')
        self._max_pwm = MutableDecopInteger(client, name + ':max-pwm')

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    @property
    def temp(self) -> 'SettableDecopReal':
        return self._temp

    @property
    def ki(self) -> 'MutableDecopInteger':
        return self._ki

    @property
    def kp(self) -> 'MutableDecopInteger':
        return self._kp

    @property
    def pwm(self) -> 'MutableDecopInteger':
        return self._pwm

    @property
    def max_pwm(self) -> 'MutableDecopInteger':
        return self._max_pwm

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Dx5100:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._serial_number = DecopString(client, name + ':serial-number')
        self._fw_ver = DecopString(client, name + ':fw-ver')

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver


class TecDx:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enable = MutableDecopBoolean(client, name + ':enable')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._temp = SettableDecopReal(client, name + ':temp')
        self._current = DecopReal(client, name + ':current')
        self._voltage = DecopReal(client, name + ':voltage')
        self._temp_min = MutableDecopReal(client, name + ':temp-min')
        self._temp_max = MutableDecopReal(client, name + ':temp-max')
        self._kp = MutableDecopReal(client, name + ':kp')
        self._ki = MutableDecopReal(client, name + ':ki')
        self._kd = MutableDecopReal(client, name + ':kd')
        self._calibration = Thermistor(client, name + ':calibration')

    @property
    def enable(self) -> 'MutableDecopBoolean':
        return self._enable

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def temp(self) -> 'SettableDecopReal':
        return self._temp

    @property
    def current(self) -> 'DecopReal':
        return self._current

    @property
    def voltage(self) -> 'DecopReal':
        return self._voltage

    @property
    def temp_min(self) -> 'MutableDecopReal':
        return self._temp_min

    @property
    def temp_max(self) -> 'MutableDecopReal':
        return self._temp_max

    @property
    def kp(self) -> 'MutableDecopReal':
        return self._kp

    @property
    def ki(self) -> 'MutableDecopReal':
        return self._ki

    @property
    def kd(self) -> 'MutableDecopReal':
        return self._kd

    @property
    def calibration(self) -> 'Thermistor':
        return self._calibration

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Thermistor:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name

    async def get(self) -> Tuple[bool, float, float, float, float, float, float]:
        return await self.__client.get(self.__name)

    async def set(self, polynomial: bool, a0: float, a1: float, a2: float, a3: float, a4: float, a5: float) -> None:
        assert isinstance(polynomial, bool), f"expected type 'bool' for 'polynomial', got '{type(polynomial)}'"
        assert isinstance(a0, float), f"expected type 'float' for 'a0', got '{type(a0)}'"
        assert isinstance(a1, float), f"expected type 'float' for 'a1', got '{type(a1)}'"
        assert isinstance(a2, float), f"expected type 'float' for 'a2', got '{type(a2)}'"
        assert isinstance(a3, float), f"expected type 'float' for 'a3', got '{type(a3)}'"
        assert isinstance(a4, float), f"expected type 'float' for 'a4', got '{type(a4)}'"
        assert isinstance(a5, float), f"expected type 'float' for 'a5', got '{type(a5)}'"
        await self.__client.set(self.__name, polynomial, a0, a1, a2, a3, a4, a5)


class Powermon:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cal = DecopReal(client, name + ':cal')
        self._cal_udelay = MutableDecopInteger(client, name + ':cal-udelay')
        self._ext = DecopReal(client, name + ':ext')
        self._signal = DecopReal(client, name + ':signal')
        self._signal_source = MutableDecopString(client, name + ':signal-source')
        self._ext_address = MutableDecopString(client, name + ':ext-address')
        self._ext_wavelength = MutableDecopReal(client, name + ':ext-wavelength')
        self._ext_udelay = MutableDecopInteger(client, name + ':ext-udelay')

    @property
    def cal(self) -> 'DecopReal':
        return self._cal

    @property
    def cal_udelay(self) -> 'MutableDecopInteger':
        return self._cal_udelay

    @property
    def ext(self) -> 'DecopReal':
        return self._ext

    @property
    def signal(self) -> 'DecopReal':
        return self._signal

    @property
    def signal_source(self) -> 'MutableDecopString':
        return self._signal_source

    @property
    def ext_address(self) -> 'MutableDecopString':
        return self._ext_address

    @property
    def ext_wavelength(self) -> 'MutableDecopReal':
        return self._ext_wavelength

    @property
    def ext_udelay(self) -> 'MutableDecopInteger':
        return self._ext_udelay


class Buzzer:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._welcome = MutableDecopString(client, name + ':welcome')

    @property
    def welcome(self) -> 'MutableDecopString':
        return self._welcome

    async def play_welcome(self) -> None:
        await self.__client.exec(self.__name + ':play-welcome', input_stream=None, output_type=None, return_type=None)

    async def play(self, melody: str) -> None:
        assert isinstance(melody, str), f"expected type 'str' for parameter 'melody', got '{type(melody)}'"
        await self.__client.exec(self.__name + ':play', melody, input_stream=None, output_type=None, return_type=None)


class Ipconfig:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ip_addr = DecopString(client, name + ':ip-addr')
        self._net_mask = DecopString(client, name + ':net-mask')
        self._mac_addr = DecopString(client, name + ':mac-addr')
        self._dhcp = DecopBoolean(client, name + ':dhcp')
        self._cmd_port = DecopInteger(client, name + ':cmd-port')
        self._mon_port = DecopInteger(client, name + ':mon-port')

    @property
    def ip_addr(self) -> 'DecopString':
        return self._ip_addr

    @property
    def net_mask(self) -> 'DecopString':
        return self._net_mask

    @property
    def mac_addr(self) -> 'DecopString':
        return self._mac_addr

    @property
    def dhcp(self) -> 'DecopBoolean':
        return self._dhcp

    @property
    def cmd_port(self) -> 'DecopInteger':
        return self._cmd_port

    @property
    def mon_port(self) -> 'DecopInteger':
        return self._mon_port

    async def set_dhcp(self) -> None:
        await self.__client.exec(self.__name + ':set-dhcp', input_stream=None, output_type=None, return_type=None)

    async def set_ip(self, ip_addr: str, net_mask: str) -> None:
        assert isinstance(ip_addr, str), f"expected type 'str' for parameter 'ip_addr', got '{type(ip_addr)}'"
        assert isinstance(net_mask, str), f"expected type 'str' for parameter 'net_mask', got '{type(net_mask)}'"
        await self.__client.exec(self.__name + ':set-ip', ip_addr, net_mask, input_stream=None, output_type=None, return_type=None)

    async def apply(self) -> None:
        await self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)


class Optparams:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._initial_stepsize = MutableDecopInteger(client, name + ':initial-stepsize')
        self._minimum_stepsize = MutableDecopInteger(client, name + ':minimum-stepsize')
        self._last_chance_tolerance = MutableDecopReal(client, name + ':last-chance-tolerance')
        self._last_chance_initial_stepsize = MutableDecopInteger(client, name + ':last-chance-initial-stepsize')
        self._last_chance_minimum_stepsize = MutableDecopInteger(client, name + ':last-chance-minimum-stepsize')
        self._min_power_ext = MutableDecopReal(client, name + ':min-power-ext')
        self._min_power_cal = MutableDecopReal(client, name + ':min-power-cal')
        self._min_power_fiber = MutableDecopReal(client, name + ':min-power-fiber')
        self._keep_level = MutableDecopBoolean(client, name + ':keep-level')
        self._debug = MutableDecopBoolean(client, name + ':debug')
        self._undo_step = MutableDecopBoolean(client, name + ':undo-step')
        self._step_delay = MutableDecopInteger(client, name + ':step-delay')
        self._averaging = MutableDecopInteger(client, name + ':averaging')
        self._max_tries = MutableDecopInteger(client, name + ':max-tries')
        self._analog_threshold = MutableDecopInteger(client, name + ':analog-threshold')

    @property
    def initial_stepsize(self) -> 'MutableDecopInteger':
        return self._initial_stepsize

    @property
    def minimum_stepsize(self) -> 'MutableDecopInteger':
        return self._minimum_stepsize

    @property
    def last_chance_tolerance(self) -> 'MutableDecopReal':
        return self._last_chance_tolerance

    @property
    def last_chance_initial_stepsize(self) -> 'MutableDecopInteger':
        return self._last_chance_initial_stepsize

    @property
    def last_chance_minimum_stepsize(self) -> 'MutableDecopInteger':
        return self._last_chance_minimum_stepsize

    @property
    def min_power_ext(self) -> 'MutableDecopReal':
        return self._min_power_ext

    @property
    def min_power_cal(self) -> 'MutableDecopReal':
        return self._min_power_cal

    @property
    def min_power_fiber(self) -> 'MutableDecopReal':
        return self._min_power_fiber

    @property
    def keep_level(self) -> 'MutableDecopBoolean':
        return self._keep_level

    @property
    def debug(self) -> 'MutableDecopBoolean':
        return self._debug

    @property
    def undo_step(self) -> 'MutableDecopBoolean':
        return self._undo_step

    @property
    def step_delay(self) -> 'MutableDecopInteger':
        return self._step_delay

    @property
    def averaging(self) -> 'MutableDecopInteger':
        return self._averaging

    @property
    def max_tries(self) -> 'MutableDecopInteger':
        return self._max_tries

    @property
    def analog_threshold(self) -> 'MutableDecopInteger':
        return self._analog_threshold

    async def store_config(self) -> None:
        await self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Pcbs:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cpu = Pcb(client, name + ':cpu')

    @property
    def cpu(self) -> 'Pcb':
        return self._cpu


class Pcb:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._revision = DecopInteger(client, name + ':revision')
        self._revstr = DecopString(client, name + ':revstr')
        self._memo = DecopString(client, name + ':memo')

    @property
    def revision(self) -> 'DecopInteger':
        return self._revision

    @property
    def revstr(self) -> 'DecopString':
        return self._revstr

    @property
    def memo(self) -> 'DecopString':
        return self._memo


class Scripts:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._boot = Script(client, name + ':boot')
        self._console = Script(client, name + ':console')
        self._misc = Script(client, name + ':misc')

    @property
    def boot(self) -> 'Script':
        return self._boot

    @property
    def console(self) -> 'Script':
        return self._console

    @property
    def misc(self) -> 'Script':
        return self._misc


class Script:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._busy = DecopBoolean(client, name + ':busy')
        self._size = DecopInteger(client, name + ':size')

    @property
    def busy(self) -> 'DecopBoolean':
        return self._busy

    @property
    def size(self) -> 'DecopInteger':
        return self._size

    async def txt(self) -> str:
        return await self.__client.exec(self.__name + ':txt', input_stream=None, output_type=None, return_type=str)

    async def disp(self) -> str:
        return await self.__client.exec(self.__name + ':disp', input_stream=None, output_type=str, return_type=None)

    async def store(self, newtxt: str) -> None:
        assert isinstance(newtxt, str), f"expected type 'str' for parameter 'newtxt', got '{type(newtxt)}'"
        await self.__client.exec(self.__name + ':store', newtxt, input_stream=None, output_type=None, return_type=None)

    async def read(self) -> bytes:
        return await self.__client.exec(self.__name + ':read', input_stream=None, output_type=bytes, return_type=None)

    async def write(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        await self.__client.exec(self.__name + ':write', input_stream=input_stream, output_type=None, return_type=None)

    async def exec(self) -> None:
        await self.__client.exec(self.__name + ':exec', input_stream=None, output_type=None, return_type=None)

    async def start(self) -> None:
        await self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    async def stop(self) -> None:
        await self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)


class CLE:
    def __init__(self, connection: Connection) -> None:
        self.__client = Client(connection)
        self._laser1 = Laser(self.__client, 'laser1')
        self._laser2 = Laser(self.__client, 'laser2')
        self._laser3 = Laser(self.__client, 'laser3')
        self._laser4 = Laser(self.__client, 'laser4')
        self._all = AllLasers(self.__client, 'all')
        self._tec_d = Tec(self.__client, 'tec-d')
        self._tec_l = Tec(self.__client, 'tec-l')
        self._dx5100 = Dx5100(self.__client, 'dx5100')
        self._tec_c = TecDx(self.__client, 'tec-c')
        self._tec_p = TecDx(self.__client, 'tec-p')
        self._powermon = Powermon(self.__client, 'powermon')
        self._photodiode2 = DecopInteger(self.__client, 'photodiode2')
        self._interlock = DecopBoolean(self.__client, 'interlock')
        self._voltage = DecopReal(self.__client, 'voltage')
        self._current = DecopReal(self.__client, 'current')
        self._base_temp = DecopReal(self.__client, 'base-temp')
        self._tec_loop_delay = MutableDecopReal(self.__client, 'tec-loop-delay')
        self._buzzer = Buzzer(self.__client, 'buzzer')
        self._tan = DecopInteger(self.__client, 'tan')
        self._uptime = DecopInteger(self.__client, 'uptime')
        self._uptime_txt = DecopString(self.__client, 'uptime-txt')
        self._time = MutableDecopString(self.__client, 'time')
        self._fw_ver = DecopString(self.__client, 'fw-ver')
        self._decof_ver = DecopString(self.__client, 'decof-ver')
        self._serial_number = DecopString(self.__client, 'serial-number')
        self._system_type = DecopString(self.__client, 'system-type')
        self._system_model = DecopString(self.__client, 'system-model')
        self._system_label = MutableDecopString(self.__client, 'system-label')
        self._ul = MutableDecopInteger(self.__client, 'ul')
        self._net_conf = Ipconfig(self.__client, 'net-conf')
        self._echo = MutableDecopBoolean(self.__client, 'echo')
        self._opt_params = Optparams(self.__client, 'opt-params')
        self._pcb = Pcbs(self.__client, 'pcb')
        self._script = Scripts(self.__client, 'script')

    def __enter__(self):
        return self

    def __exit__(self):
        raise RuntimeError()

    async def __aenter__(self):
        await self.open()
        return self

    async def __aexit__(self, *args):
        await self.close()

    def __await__(self):
        return self.__aenter__().__await__()

    async def open(self) -> None:
        await self.__client.open()

    async def close(self) -> None:
        await self.__client.close()

    @property
    def laser1(self) -> 'Laser':
        return self._laser1

    @property
    def laser2(self) -> 'Laser':
        return self._laser2

    @property
    def laser3(self) -> 'Laser':
        return self._laser3

    @property
    def laser4(self) -> 'Laser':
        return self._laser4

    @property
    def all(self) -> 'AllLasers':
        return self._all

    @property
    def tec_d(self) -> 'Tec':
        return self._tec_d

    @property
    def tec_l(self) -> 'Tec':
        return self._tec_l

    @property
    def dx5100(self) -> 'Dx5100':
        return self._dx5100

    @property
    def tec_c(self) -> 'TecDx':
        return self._tec_c

    @property
    def tec_p(self) -> 'TecDx':
        return self._tec_p

    @property
    def powermon(self) -> 'Powermon':
        return self._powermon

    @property
    def photodiode2(self) -> 'DecopInteger':
        return self._photodiode2

    @property
    def interlock(self) -> 'DecopBoolean':
        return self._interlock

    @property
    def voltage(self) -> 'DecopReal':
        return self._voltage

    @property
    def current(self) -> 'DecopReal':
        return self._current

    @property
    def base_temp(self) -> 'DecopReal':
        return self._base_temp

    @property
    def tec_loop_delay(self) -> 'MutableDecopReal':
        return self._tec_loop_delay

    @property
    def buzzer(self) -> 'Buzzer':
        return self._buzzer

    @property
    def tan(self) -> 'DecopInteger':
        return self._tan

    @property
    def uptime(self) -> 'DecopInteger':
        return self._uptime

    @property
    def uptime_txt(self) -> 'DecopString':
        return self._uptime_txt

    @property
    def time(self) -> 'MutableDecopString':
        return self._time

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver

    @property
    def decof_ver(self) -> 'DecopString':
        return self._decof_ver

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def system_type(self) -> 'DecopString':
        return self._system_type

    @property
    def system_model(self) -> 'DecopString':
        return self._system_model

    @property
    def system_label(self) -> 'MutableDecopString':
        return self._system_label

    @property
    def ul(self) -> 'MutableDecopInteger':
        return self._ul

    @property
    def net_conf(self) -> 'Ipconfig':
        return self._net_conf

    @property
    def echo(self) -> 'MutableDecopBoolean':
        return self._echo

    @property
    def opt_params(self) -> 'Optparams':
        return self._opt_params

    @property
    def pcb(self) -> 'Pcbs':
        return self._pcb

    @property
    def script(self) -> 'Scripts':
        return self._script

    async def hello(self) -> None:
        await self.__client.exec('hello', input_stream=None, output_type=None, return_type=None)

    async def fw_update(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        await self.__client.exec('fw-update', input_stream=input_stream, output_type=None, return_type=None)

    async def save_counters(self) -> int:
        return await self.__client.exec('save-counters', input_stream=None, output_type=None, return_type=int)

    async def debuglog(self) -> str:
        return await self.__client.exec('debuglog', input_stream=None, output_type=str, return_type=None)

    async def servicelog(self) -> str:
        return await self.__client.exec('servicelog', input_stream=None, output_type=str, return_type=None)

    async def errorlog(self) -> str:
        return await self.__client.exec('errorlog', input_stream=None, output_type=str, return_type=None)

    async def summary(self) -> str:
        return await self.__client.exec('summary', input_stream=None, output_type=str, return_type=None)

    async def service_report(self) -> bytes:
        return await self.__client.exec('service-report', input_stream=None, output_type=bytes, return_type=None)

    async def restore_factory_settings(self) -> None:
        await self.__client.exec('restore-factory-settings', input_stream=None, output_type=None, return_type=None)

    async def reboot_device(self) -> None:
        await self.__client.exec('reboot-device', input_stream=None, output_type=None, return_type=None)

    async def change_ul(self, ul: UserLevel, password: Optional[str] = None) -> int:
        assert isinstance(ul, UserLevel), f"expected type 'UserLevel' for parameter 'ul', got '{type(ul)}'"
        assert isinstance(password, str) or password is None, f"expected type 'str' or 'None' for parameter 'password', got '{type(password)}'"
        return await self.__client.change_ul(ul, password)

    async def change_password(self, passwd: str) -> None:
        assert isinstance(passwd, str), f"expected type 'str' for parameter 'passwd', got '{type(passwd)}'"
        await self.__client.exec('change-password', passwd, input_stream=None, output_type=None, return_type=None)

    async def read_config(self) -> bytes:
        return await self.__client.exec('read-config', input_stream=None, output_type=bytes, return_type=None)

