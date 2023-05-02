# Generated from 'v2_2_0.xml' on 2023-03-13 11:43:15.922293

from typing import Tuple
from typing import Optional

from toptica.lasersdk.client import UserLevel
from toptica.lasersdk.client import Client

from toptica.lasersdk.client import DecopError
from toptica.lasersdk.client import DeviceNotFoundError

from toptica.lasersdk.client import DecopBoolean
from toptica.lasersdk.client import DecopInteger
from toptica.lasersdk.client import DecopReal
from toptica.lasersdk.client import DecopString
from toptica.lasersdk.client import DecopBinary

from toptica.lasersdk.client import MutableDecopBoolean
from toptica.lasersdk.client import MutableDecopInteger
from toptica.lasersdk.client import MutableDecopReal
from toptica.lasersdk.client import MutableDecopString
from toptica.lasersdk.client import MutableDecopBinary

from toptica.lasersdk.client import SettableDecopBoolean
from toptica.lasersdk.client import SettableDecopInteger
from toptica.lasersdk.client import SettableDecopReal
from toptica.lasersdk.client import SettableDecopString
from toptica.lasersdk.client import SettableDecopBinary

from toptica.lasersdk.client import Subscription
from toptica.lasersdk.client import Timestamp
from toptica.lasersdk.client import SubscriptionValue

from toptica.lasersdk.client import Connection
from toptica.lasersdk.client import SerialConnection

import toptica.lasersdk.client


class NetworkConnection(toptica.lasersdk.client.NetworkConnection):
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
        self._analog_mode = MutableDecopBoolean(client, name + ':analog-mode')
        self._use_ttl = MutableDecopBoolean(client, name + ':use-ttl')
        self._fine = Fine(client, name + ':fine')
        self._delay = MutableDecopInteger(client, name + ':delay')
        self._entime = DecopInteger(client, name + ':entime')
        self._entime_txt = DecopString(client, name + ':entime-txt')
        self._sensorgain = MutableDecopInteger(client, name + ':sensorgain')
        self._internal100 = MutableDecopInteger(client, name + ':internal100')
        self._diode = Diode(client, name + ':diode')
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
    def sensorgain(self) -> 'MutableDecopInteger':
        return self._sensorgain

    @property
    def internal100(self) -> 'MutableDecopInteger':
        return self._internal100

    @property
    def diode(self) -> 'Diode':
        return self._diode

    @property
    def beam(self) -> 'Beam':
        return self._beam

    def reset_clip(self) -> None:
        self.__client.exec(self.__name + ':reset-clip', input_stream=None, output_type=None, return_type=None)

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    def gen_lookup(self) -> None:
        self.__client.exec(self.__name + ':gen-lookup', input_stream=None, output_type=None, return_type=None)

    def disp_lookup(self) -> None:
        self.__client.exec(self.__name + ':disp-lookup', input_stream=None, output_type=None, return_type=None)

    def store_lookup(self) -> None:
        self.__client.exec(self.__name + ':store-lookup', input_stream=None, output_type=None, return_type=None)

    def load_lookup(self) -> None:
        self.__client.exec(self.__name + ':load-lookup', input_stream=None, output_type=None, return_type=None)

    def clear_lookup(self) -> None:
        self.__client.exec(self.__name + ':clear-lookup', input_stream=None, output_type=None, return_type=None)

    def check_lookup(self) -> float:
        return self.__client.exec(self.__name + ':check-lookup', input_stream=None, output_type=None, return_type=float)

    def set_internal100(self) -> None:
        self.__client.exec(self.__name + ':set-internal100', input_stream=None, output_type=None, return_type=None)

    def set_external100(self, power: float) -> None:
        assert isinstance(power, float), f"expected type 'float' for parameter 'power', got '{type(power)}'"
        self.__client.exec(self.__name + ':set-external100', power, input_stream=None, output_type=None, return_type=None)

    def check_level(self) -> float:
        return self.__client.exec(self.__name + ':check-level', input_stream=None, output_type=None, return_type=float)

    def recalibrate(self) -> None:
        self.__client.exec(self.__name + ':recalibrate', input_stream=None, output_type=None, return_type=None)

    def store_calibration(self) -> None:
        self.__client.exec(self.__name + ':store-calibration', input_stream=None, output_type=None, return_type=None)

    def wait(self) -> None:
        self.__client.exec(self.__name + ':wait', input_stream=None, output_type=None, return_type=None)

    def restore_settings(self) -> None:
        self.__client.exec(self.__name + ':restore-settings', input_stream=None, output_type=None, return_type=None)


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


class Beam:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._center = Position(client, name + ':center')
        self._radius = MutableDecopReal(client, name + ':radius')
        self._targetpos = Position(client, name + ':targetpos')
        self._targetcoupling = MutableDecopReal(client, name + ':targetcoupling')
        self._cam_threshold = MutableDecopInteger(client, name + ':cam-threshold')
        self._cam_exposure = MutableDecopInteger(client, name + ':cam-exposure')
        self._cam_gain = MutableDecopInteger(client, name + ':cam-gain')
        self._cam_laserlevel = MutableDecopInteger(client, name + ':cam-laserlevel')
        self._drive_a = Elliptec(client, name + ':drive-a')
        self._drive_b = Elliptec(client, name + ':drive-b')

    @property
    def center(self) -> 'Position':
        return self._center

    @property
    def radius(self) -> 'MutableDecopReal':
        return self._radius

    @property
    def targetpos(self) -> 'Position':
        return self._targetpos

    @property
    def targetcoupling(self) -> 'MutableDecopReal':
        return self._targetcoupling

    @property
    def cam_threshold(self) -> 'MutableDecopInteger':
        return self._cam_threshold

    @property
    def cam_exposure(self) -> 'MutableDecopInteger':
        return self._cam_exposure

    @property
    def cam_gain(self) -> 'MutableDecopInteger':
        return self._cam_gain

    @property
    def cam_laserlevel(self) -> 'MutableDecopInteger':
        return self._cam_laserlevel

    @property
    def drive_a(self) -> 'Elliptec':
        return self._drive_a

    @property
    def drive_b(self) -> 'Elliptec':
        return self._drive_b

    def shiftpolar(self, radial: int, tangential: int) -> None:
        assert isinstance(radial, int), f"expected type 'int' for parameter 'radial', got '{type(radial)}'"
        assert isinstance(tangential, int), f"expected type 'int' for parameter 'tangential', got '{type(tangential)}'"
        self.__client.exec(self.__name + ':shiftpolar', radial, tangential, input_stream=None, output_type=None, return_type=None)

    def shift(self, step_a: int, step_b: int) -> None:
        assert isinstance(step_a, int), f"expected type 'int' for parameter 'step_a', got '{type(step_a)}'"
        assert isinstance(step_b, int), f"expected type 'int' for parameter 'step_b', got '{type(step_b)}'"
        self.__client.exec(self.__name + ':shift', step_a, step_b, input_stream=None, output_type=None, return_type=None)

    def moveto(self, xposition: float, yposition: float) -> None:
        assert isinstance(xposition, float), f"expected type 'float' for parameter 'xposition', got '{type(xposition)}'"
        assert isinstance(yposition, float), f"expected type 'float' for parameter 'yposition', got '{type(yposition)}'"
        self.__client.exec(self.__name + ':moveto', xposition, yposition, input_stream=None, output_type=None, return_type=None)

    def gohome(self) -> None:
        self.__client.exec(self.__name + ':gohome', input_stream=None, output_type=None, return_type=None)

    def sethome(self, use_current_settings: bool) -> None:
        assert isinstance(use_current_settings, bool), f"expected type 'bool' for parameter 'use_current_settings', got '{type(use_current_settings)}'"
        self.__client.exec(self.__name + ':sethome', use_current_settings, input_stream=None, output_type=None, return_type=None)

    def newhome(self) -> None:
        self.__client.exec(self.__name + ':newhome', input_stream=None, output_type=None, return_type=None)

    def getpos(self) -> None:
        return self.__client.exec(self.__name + ':getpos', input_stream=None, output_type=None, return_type=None)

    def newcenter(self) -> None:
        self.__client.exec(self.__name + ':newcenter', input_stream=None, output_type=None, return_type=None)

    def checkcenter(self) -> None:
        return self.__client.exec(self.__name + ':checkcenter', input_stream=None, output_type=None, return_type=None)

    def gocenter(self) -> None:
        self.__client.exec(self.__name + ':gocenter', input_stream=None, output_type=None, return_type=None)

    def optimize(self) -> None:
        self.__client.exec(self.__name + ':optimize', input_stream=None, output_type=None, return_type=None)

    def scan(self) -> None:
        self.__client.exec(self.__name + ':scan', input_stream=None, output_type=None, return_type=None)

    def history(self) -> Tuple[str, int]:
        return self.__client.exec(self.__name + ':history', input_stream=None, output_type=str, return_type=int)

    def goback(self) -> None:
        self.__client.exec(self.__name + ':goback', input_stream=None, output_type=None, return_type=None)

    def gofwd(self) -> None:
        self.__client.exec(self.__name + ':gofwd', input_stream=None, output_type=None, return_type=None)

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Position:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name

    def get(self) -> Tuple[float, float]:
        return self.__client.get(self.__name)

    def set(self, x: float, y: float) -> None:
        assert isinstance(x, float), f"expected type 'float' for 'x', got '{type(x)}'"
        assert isinstance(y, float), f"expected type 'float' for 'y', got '{type(y)}'"
        self.__client.set(self.__name, x, y)


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

    def findfreqs(self) -> str:
        return self.__client.exec(self.__name + ':findfreqs', input_stream=None, output_type=str, return_type=None)

    def refinefreqs(self) -> str:
        return self.__client.exec(self.__name + ':refinefreqs', input_stream=None, output_type=str, return_type=None)

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    def move(self, time: int) -> None:
        assert isinstance(time, int), f"expected type 'int' for parameter 'time', got '{type(time)}'"
        self.__client.exec(self.__name + ':move', time, input_stream=None, output_type=None, return_type=None)

    def fwd(self) -> None:
        self.__client.exec(self.__name + ':fwd', input_stream=None, output_type=None, return_type=None)

    def back(self) -> None:
        self.__client.exec(self.__name + ':back', input_stream=None, output_type=None, return_type=None)

    def run(self, frequency: int) -> int:
        assert isinstance(frequency, int), f"expected type 'int' for parameter 'frequency', got '{type(frequency)}'"
        return self.__client.exec(self.__name + ':run', frequency, input_stream=None, output_type=None, return_type=int)

    def stop(self) -> None:
        self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)

    def find_center(self) -> None:
        return self.__client.exec(self.__name + ':find-center', input_stream=None, output_type=None, return_type=None)


class Dpss:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._dac8 = MutableDecopInteger(client, name + ':dac8')
        self._current = DecopReal(client, name + ':current')
        self._power = DecopReal(client, name + ':power')
        self._analog_clip = MutableDecopBoolean(client, name + ':analog-clip')

    @property
    def dac8(self) -> 'MutableDecopInteger':
        return self._dac8

    @property
    def current(self) -> 'DecopReal':
        return self._current

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def analog_clip(self) -> 'MutableDecopBoolean':
        return self._analog_clip


class Ibeam:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._attached = MutableDecopBoolean(client, name + ':attached')
        self._serial = DecopString(client, name + ':serial')
        self._laser_on_time = DecopString(client, name + ':laser-on-time')
        self._power_up_time = DecopString(client, name + ':power-up-time')
        self._cmd_timeout = MutableDecopInteger(client, name + ':cmd-timeout')
        self._update_delay = MutableDecopInteger(client, name + ':update-delay')
        self._search_delay = MutableDecopInteger(client, name + ':search-delay')

    @property
    def attached(self) -> 'MutableDecopBoolean':
        return self._attached

    @property
    def serial(self) -> 'DecopString':
        return self._serial

    @property
    def laser_on_time(self) -> 'DecopString':
        return self._laser_on_time

    @property
    def power_up_time(self) -> 'DecopString':
        return self._power_up_time

    @property
    def cmd_timeout(self) -> 'MutableDecopInteger':
        return self._cmd_timeout

    @property
    def update_delay(self) -> 'MutableDecopInteger':
        return self._update_delay

    @property
    def search_delay(self) -> 'MutableDecopInteger':
        return self._search_delay

    def cmd(self, cmd_string: str) -> None:
        assert isinstance(cmd_string, str), f"expected type 'str' for parameter 'cmd_string', got '{type(cmd_string)}'"
        self.__client.exec(self.__name + ':cmd', cmd_string, input_stream=None, output_type=None, return_type=None)

    def reset_system(self) -> None:
        self.__client.exec(self.__name + ':reset-system', input_stream=None, output_type=None, return_type=None)


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
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    def reset_clip(self) -> None:
        self.__client.exec(self.__name + ':reset-clip', input_stream=None, output_type=None, return_type=None)

    def recalibrate(self) -> None:
        self.__client.exec(self.__name + ':recalibrate', input_stream=None, output_type=None, return_type=None)

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)

    def restore_settings(self) -> None:
        self.__client.exec(self.__name + ':restore-settings', input_stream=None, output_type=None, return_type=None)


class Cam:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on = MutableDecopBoolean(client, name + ':on')
        self._exposure = CamSetting(client, name + ':exposure')
        self._gain = CamSetting(client, name + ':gain')
        self._roi = Rect(client, name + ':roi')
        self._roi_default = Rect(client, name + ':roi-default')
        self._roi_full = Rect(client, name + ':roi-full')
        self._threshold = MutableDecopInteger(client, name + ':threshold')
        self._result_pos = Position(client, name + ':result-pos')

    @property
    def on(self) -> 'MutableDecopBoolean':
        return self._on

    @property
    def exposure(self) -> 'CamSetting':
        return self._exposure

    @property
    def gain(self) -> 'CamSetting':
        return self._gain

    @property
    def roi(self) -> 'Rect':
        return self._roi

    @property
    def roi_default(self) -> 'Rect':
        return self._roi_default

    @property
    def roi_full(self) -> 'Rect':
        return self._roi_full

    @property
    def threshold(self) -> 'MutableDecopInteger':
        return self._threshold

    @property
    def result_pos(self) -> 'Position':
        return self._result_pos

    def grab(self) -> None:
        self.__client.exec(self.__name + ':grab', input_stream=None, output_type=None, return_type=None)

    def max_level(self) -> int:
        return self.__client.exec(self.__name + ':max-level', input_stream=None, output_type=None, return_type=int)

    def com(self) -> None:
        self.__client.exec(self.__name + ':com', input_stream=None, output_type=None, return_type=None)

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class CamSetting:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._min = DecopInteger(client, name + ':min')
        self._max = DecopInteger(client, name + ':max')
        self._default = DecopInteger(client, name + ':default')
        self._value = MutableDecopInteger(client, name + ':value')

    @property
    def min(self) -> 'DecopInteger':
        return self._min

    @property
    def max(self) -> 'DecopInteger':
        return self._max

    @property
    def default(self) -> 'DecopInteger':
        return self._default

    @property
    def value(self) -> 'MutableDecopInteger':
        return self._value

    def auto_adjust(self) -> int:
        return self.__client.exec(self.__name + ':auto-adjust', input_stream=None, output_type=None, return_type=int)


class Rect:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name

    def get(self) -> Tuple[int, int, int, int]:
        return self.__client.get(self.__name)

    def set(self, left: int, top: int, width: int, height: int) -> None:
        assert isinstance(left, int), f"expected type 'int' for 'left', got '{type(left)}'"
        assert isinstance(top, int), f"expected type 'int' for 'top', got '{type(top)}'"
        assert isinstance(width, int), f"expected type 'int' for 'width', got '{type(width)}'"
        assert isinstance(height, int), f"expected type 'int' for 'height', got '{type(height)}'"
        self.__client.set(self.__name, left, top, width, height)


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
        self._available = MutableDecopBoolean(client, name + ':available')

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

    @property
    def available(self) -> 'MutableDecopBoolean':
        return self._available

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Powermon:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._int = DecopReal(client, name + ':int')
        self._int_gain = MutableDecopInteger(client, name + ':int-gain')
        self._fiber = DecopReal(client, name + ':fiber')
        self._fiber_gain = MutableDecopInteger(client, name + ':fiber-gain')
        self._coupling = DecopReal(client, name + ':coupling')
        self._coupling_gain = DecopInteger(client, name + ':coupling-gain')
        self._cal = DecopReal(client, name + ':cal')
        self._cal_udelay = MutableDecopInteger(client, name + ':cal-udelay')
        self._ext = DecopReal(client, name + ':ext')
        self._signal = DecopReal(client, name + ':signal')
        self._signal_source = MutableDecopString(client, name + ':signal-source')
        self._ext_address = MutableDecopString(client, name + ':ext-address')
        self._ext_wavelength = MutableDecopInteger(client, name + ':ext-wavelength')
        self._ext_udelay = MutableDecopInteger(client, name + ':ext-udelay')

    @property
    def int(self) -> 'DecopReal':
        return self._int

    @property
    def int_gain(self) -> 'MutableDecopInteger':
        return self._int_gain

    @property
    def fiber(self) -> 'DecopReal':
        return self._fiber

    @property
    def fiber_gain(self) -> 'MutableDecopInteger':
        return self._fiber_gain

    @property
    def coupling(self) -> 'DecopReal':
        return self._coupling

    @property
    def coupling_gain(self) -> 'DecopInteger':
        return self._coupling_gain

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
    def ext_wavelength(self) -> 'MutableDecopInteger':
        return self._ext_wavelength

    @property
    def ext_udelay(self) -> 'MutableDecopInteger':
        return self._ext_udelay


class Shutter:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._closed = DecopBoolean(client, name + ':closed')
        self._force_closed = MutableDecopBoolean(client, name + ':force-closed')

    @property
    def closed(self) -> 'DecopBoolean':
        return self._closed

    @property
    def force_closed(self) -> 'MutableDecopBoolean':
        return self._force_closed


class Switch:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._internal = MutableDecopBoolean(client, name + ':internal')
        self._port = MutableDecopInteger(client, name + ':port')

    @property
    def internal(self) -> 'MutableDecopBoolean':
        return self._internal

    @property
    def port(self) -> 'MutableDecopInteger':
        return self._port

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Buzzer:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._welcome = MutableDecopString(client, name + ':welcome')

    @property
    def welcome(self) -> 'MutableDecopString':
        return self._welcome

    def play_welcome(self) -> None:
        self.__client.exec(self.__name + ':play-welcome', input_stream=None, output_type=None, return_type=None)

    def play(self, melody: str) -> None:
        assert isinstance(melody, str), f"expected type 'str' for parameter 'melody', got '{type(melody)}'"
        self.__client.exec(self.__name + ':play', melody, input_stream=None, output_type=None, return_type=None)


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

    def set_dhcp(self) -> None:
        self.__client.exec(self.__name + ':set-dhcp', input_stream=None, output_type=None, return_type=None)

    def set_ip(self, ip_addr: str, net_mask: str) -> None:
        assert isinstance(ip_addr, str), f"expected type 'str' for parameter 'ip_addr', got '{type(ip_addr)}'"
        assert isinstance(net_mask, str), f"expected type 'str' for parameter 'net_mask', got '{type(net_mask)}'"
        self.__client.exec(self.__name + ':set-ip', ip_addr, net_mask, input_stream=None, output_type=None, return_type=None)

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)


class Moveparams:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._st1_pr = MutableDecopReal(client, name + ':st1-pr')
        self._st1_pa = MutableDecopReal(client, name + ':st1-pa')
        self._st2_pr = MutableDecopReal(client, name + ':st2-pr')
        self._st2_pa = MutableDecopReal(client, name + ':st2-pa')
        self._st2_ir = MutableDecopReal(client, name + ':st2-ir')
        self._st2_ia = MutableDecopReal(client, name + ':st2-ia')
        self._d_zone = MutableDecopReal(client, name + ':d-zone')
        self._th_factor = MutableDecopReal(client, name + ':th-factor')

    @property
    def st1_pr(self) -> 'MutableDecopReal':
        return self._st1_pr

    @property
    def st1_pa(self) -> 'MutableDecopReal':
        return self._st1_pa

    @property
    def st2_pr(self) -> 'MutableDecopReal':
        return self._st2_pr

    @property
    def st2_pa(self) -> 'MutableDecopReal':
        return self._st2_pa

    @property
    def st2_ir(self) -> 'MutableDecopReal':
        return self._st2_ir

    @property
    def st2_ia(self) -> 'MutableDecopReal':
        return self._st2_ia

    @property
    def d_zone(self) -> 'MutableDecopReal':
        return self._d_zone

    @property
    def th_factor(self) -> 'MutableDecopReal':
        return self._th_factor

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Optparams:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._max_loops = MutableDecopInteger(client, name + ':max-loops')
        self._tolerance = MutableDecopReal(client, name + ':tolerance')
        self._scan_tolerance = MutableDecopReal(client, name + ':scan-tolerance')
        self._opt_step = MutableDecopReal(client, name + ':opt-step')
        self._scan_step = MutableDecopReal(client, name + ':scan-step')
        self._min_power_ext = MutableDecopReal(client, name + ':min-power-ext')
        self._min_power_cal = MutableDecopReal(client, name + ':min-power-cal')
        self._min_improve = MutableDecopReal(client, name + ':min-improve')
        self._timeoutsecs_opt = MutableDecopInteger(client, name + ':timeoutsecs-opt')
        self._timeoutsecs_scan = MutableDecopInteger(client, name + ':timeoutsecs-scan')
        self._keep_level = MutableDecopBoolean(client, name + ':keep-level')

    @property
    def max_loops(self) -> 'MutableDecopInteger':
        return self._max_loops

    @property
    def tolerance(self) -> 'MutableDecopReal':
        return self._tolerance

    @property
    def scan_tolerance(self) -> 'MutableDecopReal':
        return self._scan_tolerance

    @property
    def opt_step(self) -> 'MutableDecopReal':
        return self._opt_step

    @property
    def scan_step(self) -> 'MutableDecopReal':
        return self._scan_step

    @property
    def min_power_ext(self) -> 'MutableDecopReal':
        return self._min_power_ext

    @property
    def min_power_cal(self) -> 'MutableDecopReal':
        return self._min_power_cal

    @property
    def min_improve(self) -> 'MutableDecopReal':
        return self._min_improve

    @property
    def timeoutsecs_opt(self) -> 'MutableDecopInteger':
        return self._timeoutsecs_opt

    @property
    def timeoutsecs_scan(self) -> 'MutableDecopInteger':
        return self._timeoutsecs_scan

    @property
    def keep_level(self) -> 'MutableDecopBoolean':
        return self._keep_level

    def store_config(self) -> None:
        self.__client.exec(self.__name + ':store-config', input_stream=None, output_type=None, return_type=None)


class Pcbs:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cpu = Pcb(client, name + ':cpu')
        self._connect = Pcb(client, name + ':connect')
        self._camera = Pcb(client, name + ':camera')
        self._base = Pcb(client, name + ':base')
        self._dpss = Pcb(client, name + ':dpss')

    @property
    def cpu(self) -> 'Pcb':
        return self._cpu

    @property
    def connect(self) -> 'Pcb':
        return self._connect

    @property
    def camera(self) -> 'Pcb':
        return self._camera

    @property
    def base(self) -> 'Pcb':
        return self._base

    @property
    def dpss(self) -> 'Pcb':
        return self._dpss


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


class Gpio:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._in_5 = GpioIn(client, name + ':in-5')
        self._in_6 = GpioIn(client, name + ':in-6')
        self._in_7 = GpioIn(client, name + ':in-7')
        self._in_12 = GpioIn(client, name + ':in-12')
        self._in_13 = GpioIn(client, name + ':in-13')
        self._in_14 = GpioIn(client, name + ':in-14')
        self._in_15 = GpioIn(client, name + ':in-15')
        self._in_delay = MutableDecopInteger(client, name + ':in-delay')
        self._out_4 = GpioOut(client, name + ':out-4')
        self._out_8 = GpioOut(client, name + ':out-8')
        self._out_11 = GpioOut(client, name + ':out-11')
        self._out_delay = MutableDecopInteger(client, name + ':out-delay')

    @property
    def in_5(self) -> 'GpioIn':
        return self._in_5

    @property
    def in_6(self) -> 'GpioIn':
        return self._in_6

    @property
    def in_7(self) -> 'GpioIn':
        return self._in_7

    @property
    def in_12(self) -> 'GpioIn':
        return self._in_12

    @property
    def in_13(self) -> 'GpioIn':
        return self._in_13

    @property
    def in_14(self) -> 'GpioIn':
        return self._in_14

    @property
    def in_15(self) -> 'GpioIn':
        return self._in_15

    @property
    def in_delay(self) -> 'MutableDecopInteger':
        return self._in_delay

    @property
    def out_4(self) -> 'GpioOut':
        return self._out_4

    @property
    def out_8(self) -> 'GpioOut':
        return self._out_8

    @property
    def out_11(self) -> 'GpioOut':
        return self._out_11

    @property
    def out_delay(self) -> 'MutableDecopInteger':
        return self._out_delay


class GpioIn:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value = DecopBoolean(client, name + ':value')
        self._on_rising = MutableDecopString(client, name + ':on-rising')
        self._on_falling = MutableDecopString(client, name + ':on-falling')
        self._auto = MutableDecopBoolean(client, name + ':auto')

    @property
    def value(self) -> 'DecopBoolean':
        return self._value

    @property
    def on_rising(self) -> 'MutableDecopString':
        return self._on_rising

    @property
    def on_falling(self) -> 'MutableDecopString':
        return self._on_falling

    @property
    def auto(self) -> 'MutableDecopBoolean':
        return self._auto


class GpioOut:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value = MutableDecopBoolean(client, name + ':value')
        self._query = MutableDecopString(client, name + ':query')
        self._auto = MutableDecopBoolean(client, name + ':auto')

    @property
    def value(self) -> 'MutableDecopBoolean':
        return self._value

    @property
    def query(self) -> 'MutableDecopString':
        return self._query

    @property
    def auto(self) -> 'MutableDecopBoolean':
        return self._auto


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

    def txt(self) -> str:
        return self.__client.exec(self.__name + ':txt', input_stream=None, output_type=None, return_type=str)

    def disp(self) -> str:
        return self.__client.exec(self.__name + ':disp', input_stream=None, output_type=str, return_type=None)

    def store(self, newtxt: str) -> None:
        assert isinstance(newtxt, str), f"expected type 'str' for parameter 'newtxt', got '{type(newtxt)}'"
        self.__client.exec(self.__name + ':store', newtxt, input_stream=None, output_type=None, return_type=None)

    def read(self) -> bytes:
        return self.__client.exec(self.__name + ':read', input_stream=None, output_type=bytes, return_type=None)

    def write(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        self.__client.exec(self.__name + ':write', input_stream=input_stream, output_type=None, return_type=None)

    def exec(self) -> None:
        self.__client.exec(self.__name + ':exec', input_stream=None, output_type=None, return_type=None)

    def start(self) -> None:
        self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    def stop(self) -> None:
        self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)


class MLE:
    def __init__(self, connection: Connection) -> None:
        self.__client = Client(connection)
        self._laser1 = Laser(self.__client, 'laser1')
        self._laser2 = Laser(self.__client, 'laser2')
        self._laser3 = Laser(self.__client, 'laser3')
        self._laser4 = Laser(self.__client, 'laser4')
        self._laser5 = Laser(self.__client, 'laser5')
        self._dpss = Dpss(self.__client, 'dpss')
        self._ibeam = Ibeam(self.__client, 'ibeam')
        self._all = AllLasers(self.__client, 'all')
        self._cam = Cam(self.__client, 'cam')
        self._tec_d = Tec(self.__client, 'tec-d')
        self._tec_l = Tec(self.__client, 'tec-l')
        self._powermon = Powermon(self.__client, 'powermon')
        self._photodiode2 = DecopInteger(self.__client, 'photodiode2')
        self._interlock = DecopBoolean(self.__client, 'interlock')
        self._shutter = Shutter(self.__client, 'shutter')
        self._switch = Switch(self.__client, 'switch')
        self._voltage = DecopReal(self.__client, 'voltage')
        self._current = DecopReal(self.__client, 'current')
        self._base_temp = DecopReal(self.__client, 'base-temp')
        self._buzzer = Buzzer(self.__client, 'buzzer')
        self._led_mode = MutableDecopInteger(self.__client, 'led-mode')
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
        self._mo_params = Moveparams(self.__client, 'mo-params')
        self._opt_params = Optparams(self.__client, 'opt-params')
        self._pcb = Pcbs(self.__client, 'pcb')
        self._gpio = Gpio(self.__client, 'gpio')
        self._script = Scripts(self.__client, 'script')

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, *args):
        self.close()

    def open(self) -> None:
        self.__client.open()

    def close(self) -> None:
        self.__client.close()

    def run(self, timeout: int = None) -> None:
        self.__client.run(timeout)

    def stop(self) -> None:
        self.__client.stop()

    def poll(self) -> None:
        self.__client.poll()

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
    def laser5(self) -> 'Laser':
        return self._laser5

    @property
    def dpss(self) -> 'Dpss':
        return self._dpss

    @property
    def ibeam(self) -> 'Ibeam':
        return self._ibeam

    @property
    def all(self) -> 'AllLasers':
        return self._all

    @property
    def cam(self) -> 'Cam':
        return self._cam

    @property
    def tec_d(self) -> 'Tec':
        return self._tec_d

    @property
    def tec_l(self) -> 'Tec':
        return self._tec_l

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
    def shutter(self) -> 'Shutter':
        return self._shutter

    @property
    def switch(self) -> 'Switch':
        return self._switch

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
    def buzzer(self) -> 'Buzzer':
        return self._buzzer

    @property
    def led_mode(self) -> 'MutableDecopInteger':
        return self._led_mode

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
    def mo_params(self) -> 'Moveparams':
        return self._mo_params

    @property
    def opt_params(self) -> 'Optparams':
        return self._opt_params

    @property
    def pcb(self) -> 'Pcbs':
        return self._pcb

    @property
    def gpio(self) -> 'Gpio':
        return self._gpio

    @property
    def script(self) -> 'Scripts':
        return self._script

    def hello(self) -> None:
        self.__client.exec('hello', input_stream=None, output_type=None, return_type=None)

    def fw_update(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        self.__client.exec('fw-update', input_stream=input_stream, output_type=None, return_type=None)

    def save_counters(self) -> int:
        return self.__client.exec('save-counters', input_stream=None, output_type=None, return_type=int)

    def debuglog(self) -> str:
        return self.__client.exec('debuglog', input_stream=None, output_type=str, return_type=None)

    def servicelog(self) -> str:
        return self.__client.exec('servicelog', input_stream=None, output_type=str, return_type=None)

    def errorlog(self) -> str:
        return self.__client.exec('errorlog', input_stream=None, output_type=str, return_type=None)

    def summary(self) -> str:
        return self.__client.exec('summary', input_stream=None, output_type=str, return_type=None)

    def service_report(self) -> bytes:
        return self.__client.exec('service-report', input_stream=None, output_type=bytes, return_type=None)

    def restore_factory_settings(self) -> None:
        self.__client.exec('restore-factory-settings', input_stream=None, output_type=None, return_type=None)

    def reboot_device(self) -> None:
        self.__client.exec('reboot-device', input_stream=None, output_type=None, return_type=None)

    def change_ul(self, ul: UserLevel, password: Optional[str] = None) -> int:
        assert isinstance(ul, UserLevel), f"expected type 'UserLevel' for parameter 'ul', got '{type(ul)}'"
        assert isinstance(password, str) or password is None, f"expected type 'str' or 'None' for parameter 'password', got '{type(password)}'"
        return self.__client.change_ul(ul, password)

    def change_password(self, passwd: str) -> None:
        assert isinstance(passwd, str), f"expected type 'str' for parameter 'passwd', got '{type(passwd)}'"
        self.__client.exec('change-password', passwd, input_stream=None, output_type=None, return_type=None)

    def read_config(self) -> bytes:
        return self.__client.exec('read-config', input_stream=None, output_type=bytes, return_type=None)

