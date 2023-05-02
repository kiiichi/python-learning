# Generated from 'v2_7_2.xml' on 2023-03-13 11:43:12.505278

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
from toptica.lasersdk.client import NetworkConnection


class Laser:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._type = DecopString(client, name + ':type')
        self._product_name = DecopString(client, name + ':product-name')
        self._emission = DecopBoolean(client, name + ':emission')
        self._health = DecopInteger(client, name + ':health')
        self._health_txt = DecopString(client, name + ':health-txt')
        self._busy = DecopBoolean(client, name + ':busy')
        self._dl = LaserHead(client, name + ':dl')
        self._ctl = CtlT(client, name + ':ctl')
        self._amp = LaserAmp(client, name + ':amp')
        self._dpss = Dpss1(client, name + ':dpss')
        self._scan = ScanGenerator(client, name + ':scan')
        self._wide_scan = WideScan(client, name + ':wide-scan')
        self._scope = ScopeT(client, name + ':scope')
        self._recorder = Recorder(client, name + ':recorder')
        self._scan_aux = ScanGenerator(client, name + ':scan-aux')
        self._nlo = Nlo(client, name + ':nlo')
        self._uv = UvShg(client, name + ':uv')
        self._pd_ext = PdExt(client, name + ':pd-ext')
        self._power_stabilization = PwrStab(client, name + ':power-stabilization')
        self._config = LaserConfig(client, name + ':config')
        self._diagnosis = LaserDiagnosis(client, name + ':diagnosis')
        self._components = LaserComponents(client, name + ':components')

    @property
    def type(self) -> 'DecopString':
        return self._type

    @property
    def product_name(self) -> 'DecopString':
        return self._product_name

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def health(self) -> 'DecopInteger':
        return self._health

    @property
    def health_txt(self) -> 'DecopString':
        return self._health_txt

    @property
    def busy(self) -> 'DecopBoolean':
        return self._busy

    @property
    def dl(self) -> 'LaserHead':
        return self._dl

    @property
    def ctl(self) -> 'CtlT':
        return self._ctl

    @property
    def amp(self) -> 'LaserAmp':
        return self._amp

    @property
    def dpss(self) -> 'Dpss1':
        return self._dpss

    @property
    def scan(self) -> 'ScanGenerator':
        return self._scan

    @property
    def wide_scan(self) -> 'WideScan':
        return self._wide_scan

    @property
    def scope(self) -> 'ScopeT':
        return self._scope

    @property
    def recorder(self) -> 'Recorder':
        return self._recorder

    @property
    def scan_aux(self) -> 'ScanGenerator':
        return self._scan_aux

    @property
    def nlo(self) -> 'Nlo':
        return self._nlo

    @property
    def uv(self) -> 'UvShg':
        return self._uv

    @property
    def pd_ext(self) -> 'PdExt':
        return self._pd_ext

    @property
    def power_stabilization(self) -> 'PwrStab':
        return self._power_stabilization

    @property
    def config(self) -> 'LaserConfig':
        return self._config

    @property
    def diagnosis(self) -> 'LaserDiagnosis':
        return self._diagnosis

    @property
    def components(self) -> 'LaserComponents':
        return self._components

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)

    def load_head(self) -> None:
        self.__client.exec(self.__name + ':load-head', input_stream=None, output_type=None, return_type=None)


class LaserHead:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._legacy = DecopBoolean(client, name + ':legacy')
        self._type = DecopString(client, name + ':type')
        self._version = DecopString(client, name + ':version')
        self._model = DecopString(client, name + ':model')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._fru_serial_number = DecopString(client, name + ':fru-serial-number')
        self._ontime = DecopInteger(client, name + ':ontime')
        self._ontime_txt = DecopString(client, name + ':ontime-txt')
        self._cc = CurrDrv1(client, name + ':cc')
        self._tc = TcChannel1(client, name + ':tc')
        self._pc = PiezoDrv1(client, name + ':pc')
        self._lock = Lock(client, name + ':lock')
        self._pressure_compensation = PressureCompensation(client, name + ':pressure-compensation')
        self._pd = DlPd(client, name + ':pd')
        self._power_optimization = ScbPowerOptimization(client, name + ':power-optimization')
        self._servo = ServoControlServos(client, name + ':servo')
        self._eom = PiezoDrv1(client, name + ':eom')
        self._motor = DlMotorStepper(client, name + ':motor')
        self._factory_settings = LhFactory(client, name + ':factory-settings')

    @property
    def legacy(self) -> 'DecopBoolean':
        return self._legacy

    @property
    def type(self) -> 'DecopString':
        return self._type

    @property
    def version(self) -> 'DecopString':
        return self._version

    @property
    def model(self) -> 'DecopString':
        return self._model

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def fru_serial_number(self) -> 'DecopString':
        return self._fru_serial_number

    @property
    def ontime(self) -> 'DecopInteger':
        return self._ontime

    @property
    def ontime_txt(self) -> 'DecopString':
        return self._ontime_txt

    @property
    def cc(self) -> 'CurrDrv1':
        return self._cc

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc

    @property
    def pc(self) -> 'PiezoDrv1':
        return self._pc

    @property
    def lock(self) -> 'Lock':
        return self._lock

    @property
    def pressure_compensation(self) -> 'PressureCompensation':
        return self._pressure_compensation

    @property
    def pd(self) -> 'DlPd':
        return self._pd

    @property
    def power_optimization(self) -> 'ScbPowerOptimization':
        return self._power_optimization

    @property
    def servo(self) -> 'ServoControlServos':
        return self._servo

    @property
    def eom(self) -> 'PiezoDrv1':
        return self._eom

    @property
    def motor(self) -> 'DlMotorStepper':
        return self._motor

    @property
    def factory_settings(self) -> 'LhFactory':
        return self._factory_settings

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)


class CurrDrv1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._variant = DecopString(client, name + ':variant')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._emission = DecopBoolean(client, name + ':emission')
        self._current_set = MutableDecopReal(client, name + ':current-set')
        self._current_offset = MutableDecopReal(client, name + ':current-offset')
        self._current_set_dithering = MutableDecopBoolean(client, name + ':current-set-dithering')
        self._external_input = ExtInput1(client, name + ':external-input')
        self._output_filter = OutputFilter1(client, name + ':output-filter')
        self._current_act = DecopReal(client, name + ':current-act')
        self._positive_polarity = MutableDecopBoolean(client, name + ':positive-polarity')
        self._current_clip = MutableDecopReal(client, name + ':current-clip')
        self._current_clip_tuning = DecopReal(client, name + ':current-clip-tuning')
        self._use_current_clip_tuning = MutableDecopBoolean(client, name + ':use-current-clip-tuning')
        self._current_clip_limit = DecopReal(client, name + ':current-clip-limit')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._voltage_clip = MutableDecopReal(client, name + ':voltage-clip')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._pd = DecopReal(client, name + ':pd')
        self._aux = DecopReal(client, name + ':aux')
        self._snubber = MutableDecopBoolean(client, name + ':snubber')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._forced_off = MutableDecopBoolean(client, name + ':forced-off')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def current_set(self) -> 'MutableDecopReal':
        return self._current_set

    @property
    def current_offset(self) -> 'MutableDecopReal':
        return self._current_offset

    @property
    def current_set_dithering(self) -> 'MutableDecopBoolean':
        return self._current_set_dithering

    @property
    def external_input(self) -> 'ExtInput1':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter1':
        return self._output_filter

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def positive_polarity(self) -> 'MutableDecopBoolean':
        return self._positive_polarity

    @property
    def current_clip(self) -> 'MutableDecopReal':
        return self._current_clip

    @property
    def current_clip_tuning(self) -> 'DecopReal':
        return self._current_clip_tuning

    @property
    def use_current_clip_tuning(self) -> 'MutableDecopBoolean':
        return self._use_current_clip_tuning

    @property
    def current_clip_limit(self) -> 'DecopReal':
        return self._current_clip_limit

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def voltage_clip(self) -> 'MutableDecopReal':
        return self._voltage_clip

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def pd(self) -> 'DecopReal':
        return self._pd

    @property
    def aux(self) -> 'DecopReal':
        return self._aux

    @property
    def snubber(self) -> 'MutableDecopBoolean':
        return self._snubber

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def forced_off(self) -> 'MutableDecopBoolean':
        return self._forced_off


class ExtInput1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._factor = MutableDecopReal(client, name + ':factor')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def factor(self) -> 'MutableDecopReal':
        return self._factor

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled


class OutputFilter1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slew_rate = MutableDecopReal(client, name + ':slew-rate')
        self._slew_rate_enabled = MutableDecopBoolean(client, name + ':slew-rate-enabled')
        self._slew_rate_limited = DecopBoolean(client, name + ':slew-rate-limited')

    @property
    def slew_rate(self) -> 'MutableDecopReal':
        return self._slew_rate

    @property
    def slew_rate_enabled(self) -> 'MutableDecopBoolean':
        return self._slew_rate_enabled

    @property
    def slew_rate_limited(self) -> 'DecopBoolean':
        return self._slew_rate_limited


class TcChannel1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._temp_act = DecopReal(client, name + ':temp-act')
        self._temp_set = MutableDecopReal(client, name + ':temp-set')
        self._external_input = ExtInput1(client, name + ':external-input')
        self._ready = DecopBoolean(client, name + ':ready')
        self._fault = DecopBoolean(client, name + ':fault')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._t_loop = TcChannelTLoop1(client, name + ':t-loop')
        self._c_loop = TcChannelCLoop2(client, name + ':c-loop')
        self._limits = TcChannelCheck1(client, name + ':limits')
        self._current_set = DecopReal(client, name + ':current-set')
        self._current_set_min = MutableDecopReal(client, name + ':current-set-min')
        self._current_set_max = MutableDecopReal(client, name + ':current-set-max')
        self._current_act = DecopReal(client, name + ':current-act')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._resistance = DecopReal(client, name + ':resistance')
        self._ntc_series_resistance = DecopReal(client, name + ':ntc-series-resistance')
        self._ntc_parallel_resistance = DecopReal(client, name + ':ntc-parallel-resistance')
        self._temp_set_min = MutableDecopReal(client, name + ':temp-set-min')
        self._temp_set_max = MutableDecopReal(client, name + ':temp-set-max')
        self._temp_reset = MutableDecopBoolean(client, name + ':temp-reset')
        self._temp_roc_enabled = MutableDecopBoolean(client, name + ':temp-roc-enabled')
        self._temp_roc_limit = MutableDecopReal(client, name + ':temp-roc-limit')
        self._power_source = DecopInteger(client, name + ':power-source')
        self._drv_voltage = DecopReal(client, name + ':drv-voltage')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def temp_act(self) -> 'DecopReal':
        return self._temp_act

    @property
    def temp_set(self) -> 'MutableDecopReal':
        return self._temp_set

    @property
    def external_input(self) -> 'ExtInput1':
        return self._external_input

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def t_loop(self) -> 'TcChannelTLoop1':
        return self._t_loop

    @property
    def c_loop(self) -> 'TcChannelCLoop2':
        return self._c_loop

    @property
    def limits(self) -> 'TcChannelCheck1':
        return self._limits

    @property
    def current_set(self) -> 'DecopReal':
        return self._current_set

    @property
    def current_set_min(self) -> 'MutableDecopReal':
        return self._current_set_min

    @property
    def current_set_max(self) -> 'MutableDecopReal':
        return self._current_set_max

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def resistance(self) -> 'DecopReal':
        return self._resistance

    @property
    def ntc_series_resistance(self) -> 'DecopReal':
        return self._ntc_series_resistance

    @property
    def ntc_parallel_resistance(self) -> 'DecopReal':
        return self._ntc_parallel_resistance

    @property
    def temp_set_min(self) -> 'MutableDecopReal':
        return self._temp_set_min

    @property
    def temp_set_max(self) -> 'MutableDecopReal':
        return self._temp_set_max

    @property
    def temp_reset(self) -> 'MutableDecopBoolean':
        return self._temp_reset

    @property
    def temp_roc_enabled(self) -> 'MutableDecopBoolean':
        return self._temp_roc_enabled

    @property
    def temp_roc_limit(self) -> 'MutableDecopReal':
        return self._temp_roc_limit

    @property
    def power_source(self) -> 'DecopInteger':
        return self._power_source

    @property
    def drv_voltage(self) -> 'DecopReal':
        return self._drv_voltage

    def check_peltier(self) -> float:
        return self.__client.exec(self.__name + ':check-peltier', input_stream=None, output_type=None, return_type=float)


class TcChannelTLoop1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on = MutableDecopBoolean(client, name + ':on')
        self._p_gain = MutableDecopReal(client, name + ':p-gain')
        self._i_gain = MutableDecopReal(client, name + ':i-gain')
        self._d_gain = MutableDecopReal(client, name + ':d-gain')
        self._ok_tolerance = MutableDecopReal(client, name + ':ok-tolerance')
        self._ok_time = MutableDecopReal(client, name + ':ok-time')

    @property
    def on(self) -> 'MutableDecopBoolean':
        return self._on

    @property
    def p_gain(self) -> 'MutableDecopReal':
        return self._p_gain

    @property
    def i_gain(self) -> 'MutableDecopReal':
        return self._i_gain

    @property
    def d_gain(self) -> 'MutableDecopReal':
        return self._d_gain

    @property
    def ok_tolerance(self) -> 'MutableDecopReal':
        return self._ok_tolerance

    @property
    def ok_time(self) -> 'MutableDecopReal':
        return self._ok_time


class TcChannelCLoop2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on = MutableDecopBoolean(client, name + ':on')
        self._i_gain = MutableDecopReal(client, name + ':i-gain')

    @property
    def on(self) -> 'MutableDecopBoolean':
        return self._on

    @property
    def i_gain(self) -> 'MutableDecopReal':
        return self._i_gain


class TcChannelCheck1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_min = MutableDecopReal(client, name + ':temp-min')
        self._temp_max = MutableDecopReal(client, name + ':temp-max')
        self._timeout = MutableDecopInteger(client, name + ':timeout')
        self._timed_out = DecopBoolean(client, name + ':timed-out')
        self._out_of_range = DecopBoolean(client, name + ':out-of-range')

    @property
    def temp_min(self) -> 'MutableDecopReal':
        return self._temp_min

    @property
    def temp_max(self) -> 'MutableDecopReal':
        return self._temp_max

    @property
    def timeout(self) -> 'MutableDecopInteger':
        return self._timeout

    @property
    def timed_out(self) -> 'DecopBoolean':
        return self._timed_out

    @property
    def out_of_range(self) -> 'DecopBoolean':
        return self._out_of_range


class PiezoDrv1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._voltage_set = MutableDecopReal(client, name + ':voltage-set')
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._voltage_set_dithering = MutableDecopBoolean(client, name + ':voltage-set-dithering')
        self._external_input = ExtInput1(client, name + ':external-input')
        self._output_filter = OutputFilter1(client, name + ':output-filter')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._heatsink_temp = DecopReal(client, name + ':heatsink-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def voltage_set(self) -> 'MutableDecopReal':
        return self._voltage_set

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def voltage_set_dithering(self) -> 'MutableDecopBoolean':
        return self._voltage_set_dithering

    @property
    def external_input(self) -> 'ExtInput1':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter1':
        return self._output_filter

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def heatsink_temp(self) -> 'DecopReal':
        return self._heatsink_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class Lock:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._type = MutableDecopInteger(client, name + ':type')
        self._lock_without_lockpoint = MutableDecopBoolean(client, name + ':lock-without-lockpoint')
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._lock_enabled = MutableDecopBoolean(client, name + ':lock-enabled')
        self._hold = MutableDecopBoolean(client, name + ':hold')
        self._spectrum_input_channel = MutableDecopInteger(client, name + ':spectrum-input-channel')
        self._error_channel = MutableDecopInteger(client, name + ':error-channel')
        self._error_channel_inverted = MutableDecopBoolean(client, name + ':error-channel-inverted')
        self._pdh_selection = MutableDecopInteger(client, name + ':pdh-selection')
        self._pid_selection = MutableDecopInteger(client, name + ':pid-selection')
        self._falc_selection = MutableDecopInteger(client, name + ':falc-selection')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._relock = AlRelock(client, name + ':relock')
        self._reset = AlReset(client, name + ':reset')
        self._window = AlWindow(client, name + ':window')
        self._pid1 = Pid(client, name + ':pid1')
        self._pid2 = Pid(client, name + ':pid2')
        self._lockin = Lockin(client, name + ':lockin')
        self._lockpoint = AlLockpoint(client, name + ':lockpoint')
        self._candidate_filter = AlCandidateFilter(client, name + ':candidate-filter')
        self._candidates = DecopBinary(client, name + ':candidates')
        self._locking_delay = MutableDecopInteger(client, name + ':locking-delay')
        self._background_trace = DecopBinary(client, name + ':background-trace')
        self._lock_tracking = Coordinate(client, name + ':lock-tracking')

    @property
    def type(self) -> 'MutableDecopInteger':
        return self._type

    @property
    def lock_without_lockpoint(self) -> 'MutableDecopBoolean':
        return self._lock_without_lockpoint

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def lock_enabled(self) -> 'MutableDecopBoolean':
        return self._lock_enabled

    @property
    def hold(self) -> 'MutableDecopBoolean':
        return self._hold

    @property
    def spectrum_input_channel(self) -> 'MutableDecopInteger':
        return self._spectrum_input_channel

    @property
    def error_channel(self) -> 'MutableDecopInteger':
        return self._error_channel

    @property
    def error_channel_inverted(self) -> 'MutableDecopBoolean':
        return self._error_channel_inverted

    @property
    def pdh_selection(self) -> 'MutableDecopInteger':
        return self._pdh_selection

    @property
    def pid_selection(self) -> 'MutableDecopInteger':
        return self._pid_selection

    @property
    def falc_selection(self) -> 'MutableDecopInteger':
        return self._falc_selection

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def relock(self) -> 'AlRelock':
        return self._relock

    @property
    def reset(self) -> 'AlReset':
        return self._reset

    @property
    def window(self) -> 'AlWindow':
        return self._window

    @property
    def pid1(self) -> 'Pid':
        return self._pid1

    @property
    def pid2(self) -> 'Pid':
        return self._pid2

    @property
    def lockin(self) -> 'Lockin':
        return self._lockin

    @property
    def lockpoint(self) -> 'AlLockpoint':
        return self._lockpoint

    @property
    def candidate_filter(self) -> 'AlCandidateFilter':
        return self._candidate_filter

    @property
    def candidates(self) -> 'DecopBinary':
        return self._candidates

    @property
    def locking_delay(self) -> 'MutableDecopInteger':
        return self._locking_delay

    @property
    def background_trace(self) -> 'DecopBinary':
        return self._background_trace

    @property
    def lock_tracking(self) -> 'Coordinate':
        return self._lock_tracking

    def show_candidates(self) -> Tuple[str, int]:
        return self.__client.exec(self.__name + ':show-candidates', input_stream=None, output_type=str, return_type=int)

    def find_candidates(self) -> None:
        self.__client.exec(self.__name + ':find-candidates', input_stream=None, output_type=None, return_type=None)

    def select_lockpoint(self, x: float, y: float, type_: int) -> None:
        assert isinstance(x, float), f"expected type 'float' for parameter 'x', got '{type(x)}'"
        assert isinstance(y, float), f"expected type 'float' for parameter 'y', got '{type(y)}'"
        assert isinstance(type_, int), f"expected type 'int' for parameter 'type_', got '{type(type_)}'"
        self.__client.exec(self.__name + ':select-lockpoint', x, y, type_, input_stream=None, output_type=None, return_type=None)

    def close(self) -> None:
        self.__client.exec(self.__name + ':close', input_stream=None, output_type=None, return_type=None)

    def open(self) -> None:
        self.__client.exec(self.__name + ':open', input_stream=None, output_type=None, return_type=None)


class AlRelock:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._output_channel = MutableDecopInteger(client, name + ':output-channel')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._delay = MutableDecopReal(client, name + ':delay')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def output_channel(self) -> 'MutableDecopInteger':
        return self._output_channel

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def delay(self) -> 'MutableDecopReal':
        return self._delay


class AlReset:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled


class AlWindow:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._level_high = MutableDecopReal(client, name + ':level-high')
        self._level_low = MutableDecopReal(client, name + ':level-low')
        self._level_hysteresis = MutableDecopReal(client, name + ':level-hysteresis')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def level_high(self) -> 'MutableDecopReal':
        return self._level_high

    @property
    def level_low(self) -> 'MutableDecopReal':
        return self._level_low

    @property
    def level_hysteresis(self) -> 'MutableDecopReal':
        return self._level_hysteresis


class Pid:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._gain = Gain(client, name + ':gain')
        self._sign = MutableDecopBoolean(client, name + ':sign')
        self._slope = MutableDecopBoolean(client, name + ':slope')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._output_channel = MutableDecopInteger(client, name + ':output-channel')
        self._outputlimit = Outputlimit(client, name + ':outputlimit')
        self._hold = MutableDecopBoolean(client, name + ':hold')
        self._lock_state = DecopBoolean(client, name + ':lock-state')
        self._hold_state = DecopBoolean(client, name + ':hold-state')
        self._regulating_state = DecopBoolean(client, name + ':regulating-state')
        self._hold_output_on_unlock = MutableDecopBoolean(client, name + ':hold-output-on-unlock')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def gain(self) -> 'Gain':
        return self._gain

    @property
    def sign(self) -> 'MutableDecopBoolean':
        return self._sign

    @property
    def slope(self) -> 'MutableDecopBoolean':
        return self._slope

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def output_channel(self) -> 'MutableDecopInteger':
        return self._output_channel

    @property
    def outputlimit(self) -> 'Outputlimit':
        return self._outputlimit

    @property
    def hold(self) -> 'MutableDecopBoolean':
        return self._hold

    @property
    def lock_state(self) -> 'DecopBoolean':
        return self._lock_state

    @property
    def hold_state(self) -> 'DecopBoolean':
        return self._hold_state

    @property
    def regulating_state(self) -> 'DecopBoolean':
        return self._regulating_state

    @property
    def hold_output_on_unlock(self) -> 'MutableDecopBoolean':
        return self._hold_output_on_unlock


class Gain:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._p = MutableDecopReal(client, name + ':p')
        self._i = MutableDecopReal(client, name + ':i')
        self._d = MutableDecopReal(client, name + ':d')
        self._i_cutoff = MutableDecopReal(client, name + ':i-cutoff')
        self._i_cutoff_enabled = MutableDecopBoolean(client, name + ':i-cutoff-enabled')
        self._fc_ip = DecopReal(client, name + ':fc-ip')
        self._fc_pd = DecopReal(client, name + ':fc-pd')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def p(self) -> 'MutableDecopReal':
        return self._p

    @property
    def i(self) -> 'MutableDecopReal':
        return self._i

    @property
    def d(self) -> 'MutableDecopReal':
        return self._d

    @property
    def i_cutoff(self) -> 'MutableDecopReal':
        return self._i_cutoff

    @property
    def i_cutoff_enabled(self) -> 'MutableDecopBoolean':
        return self._i_cutoff_enabled

    @property
    def fc_ip(self) -> 'DecopReal':
        return self._fc_ip

    @property
    def fc_pd(self) -> 'DecopReal':
        return self._fc_pd


class Outputlimit:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._max = MutableDecopReal(client, name + ':max')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def max(self) -> 'MutableDecopReal':
        return self._max


class Lockin:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._modulation_enabled = MutableDecopBoolean(client, name + ':modulation-enabled')
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._modulation_output_channel = MutableDecopInteger(client, name + ':modulation-output-channel')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._phase_shift = MutableDecopReal(client, name + ':phase-shift')
        self._lock_level = MutableDecopReal(client, name + ':lock-level')
        self._auto_lir = AutoLir(client, name + ':auto-lir')

    @property
    def modulation_enabled(self) -> 'MutableDecopBoolean':
        return self._modulation_enabled

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def modulation_output_channel(self) -> 'MutableDecopInteger':
        return self._modulation_output_channel

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def phase_shift(self) -> 'MutableDecopReal':
        return self._phase_shift

    @property
    def lock_level(self) -> 'MutableDecopReal':
        return self._lock_level

    @property
    def auto_lir(self) -> 'AutoLir':
        return self._auto_lir


class AutoLir:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._progress = DecopInteger(client, name + ':progress')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    def start(self) -> None:
        self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    def abort(self) -> None:
        self.__client.exec(self.__name + ':abort', input_stream=None, output_type=None, return_type=None)


class AlLockpoint:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._position = Coordinate(client, name + ':position')
        self._type = DecopString(client, name + ':type')

    @property
    def position(self) -> 'Coordinate':
        return self._position

    @property
    def type(self) -> 'DecopString':
        return self._type


class Coordinate:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name

    def get(self) -> Tuple[float, float]:
        return self.__client.get(self.__name)

    def set(self, x: float, y: float) -> None:
        assert isinstance(x, float), f"expected type 'float' for 'x', got '{type(x)}'"
        assert isinstance(y, float), f"expected type 'float' for 'y', got '{type(y)}'"
        self.__client.set(self.__name, x, y)


class AlCandidateFilter:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._top = MutableDecopBoolean(client, name + ':top')
        self._bottom = MutableDecopBoolean(client, name + ':bottom')
        self._positive_edge = MutableDecopBoolean(client, name + ':positive-edge')
        self._negative_edge = MutableDecopBoolean(client, name + ':negative-edge')
        self._edge_level = MutableDecopReal(client, name + ':edge-level')
        self._peak_noise_tolerance = MutableDecopReal(client, name + ':peak-noise-tolerance')
        self._edge_min_distance = MutableDecopInteger(client, name + ':edge-min-distance')

    @property
    def top(self) -> 'MutableDecopBoolean':
        return self._top

    @property
    def bottom(self) -> 'MutableDecopBoolean':
        return self._bottom

    @property
    def positive_edge(self) -> 'MutableDecopBoolean':
        return self._positive_edge

    @property
    def negative_edge(self) -> 'MutableDecopBoolean':
        return self._negative_edge

    @property
    def edge_level(self) -> 'MutableDecopReal':
        return self._edge_level

    @property
    def peak_noise_tolerance(self) -> 'MutableDecopReal':
        return self._peak_noise_tolerance

    @property
    def edge_min_distance(self) -> 'MutableDecopInteger':
        return self._edge_min_distance


class PressureCompensation:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._air_pressure = DecopReal(client, name + ':air-pressure')
        self._factor = MutableDecopReal(client, name + ':factor')
        self._offset = DecopReal(client, name + ':offset')
        self._compensation_voltage = DecopReal(client, name + ':compensation-voltage')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def air_pressure(self) -> 'DecopReal':
        return self._air_pressure

    @property
    def factor(self) -> 'MutableDecopReal':
        return self._factor

    @property
    def offset(self) -> 'DecopReal':
        return self._offset

    @property
    def compensation_voltage(self) -> 'DecopReal':
        return self._compensation_voltage


class DlPd:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._seed = PdCal(client, name + ':seed')
        self._seed_probe = ServoControlPdCal(client, name + ':seed-probe')
        self._fiber = ServoControlPdCal(client, name + ':fiber')

    @property
    def seed(self) -> 'PdCal':
        return self._seed

    @property
    def seed_probe(self) -> 'ServoControlPdCal':
        return self._seed_probe

    @property
    def fiber(self) -> 'ServoControlPdCal':
        return self._fiber


class PdCal:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._power = DecopReal(client, name + ':power')
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class ServoControlPdCal:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._power = DecopReal(client, name + ':power')
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class ScbPowerOptimization:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ongoing = DecopBoolean(client, name + ':ongoing')
        self._progress = DecopInteger(client, name + ':progress')
        self._status = DecopInteger(client, name + ':status')
        self._status_string = DecopString(client, name + ':status-string')
        self._fiber_advanced = MutableDecopBoolean(client, name + ':fiber-advanced')
        self._stage1 = ScbStage(client, name + ':stage1')
        self._stage2 = ScbStage(client, name + ':stage2')
        self._stage3 = ScbStage(client, name + ':stage3')
        self._stage4 = ScbStage(client, name + ':stage4')
        self._progress_data_seed_probe = DecopBinary(client, name + ':progress-data-seed-probe')
        self._progress_data_amp = DecopBinary(client, name + ':progress-data-amp')
        self._progress_data_fiber = DecopBinary(client, name + ':progress-data-fiber')
        self._abort = MutableDecopBoolean(client, name + ':abort')

    @property
    def ongoing(self) -> 'DecopBoolean':
        return self._ongoing

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_string(self) -> 'DecopString':
        return self._status_string

    @property
    def fiber_advanced(self) -> 'MutableDecopBoolean':
        return self._fiber_advanced

    @property
    def stage1(self) -> 'ScbStage':
        return self._stage1

    @property
    def stage2(self) -> 'ScbStage':
        return self._stage2

    @property
    def stage3(self) -> 'ScbStage':
        return self._stage3

    @property
    def stage4(self) -> 'ScbStage':
        return self._stage4

    @property
    def progress_data_seed_probe(self) -> 'DecopBinary':
        return self._progress_data_seed_probe

    @property
    def progress_data_amp(self) -> 'DecopBinary':
        return self._progress_data_amp

    @property
    def progress_data_fiber(self) -> 'DecopBinary':
        return self._progress_data_fiber

    @property
    def abort(self) -> 'MutableDecopBoolean':
        return self._abort

    def start_optimization_all(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-all', input_stream=None, output_type=None, return_type=int)

    def start_optimization_seed_probe(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-seed-probe', input_stream=None, output_type=None, return_type=int)

    def start_optimization_amp(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-amp', input_stream=None, output_type=None, return_type=int)

    def start_optimization_fiber(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-fiber', input_stream=None, output_type=None, return_type=int)


class ScbStage:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input = ScbOptInput(client, name + ':input')
        self._progress = DecopInteger(client, name + ':progress')
        self._optimization_in_progress = DecopBoolean(client, name + ':optimization-in-progress')
        self._restore_on_abort = MutableDecopBoolean(client, name + ':restore-on-abort')
        self._restore_on_regress = MutableDecopBoolean(client, name + ':restore-on-regress')
        self._regress_tolerance = MutableDecopInteger(client, name + ':regress-tolerance')
        self._autosave_actuator_values = MutableDecopBoolean(client, name + ':autosave-actuator-values')

    @property
    def input(self) -> 'ScbOptInput':
        return self._input

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def optimization_in_progress(self) -> 'DecopBoolean':
        return self._optimization_in_progress

    @property
    def restore_on_abort(self) -> 'MutableDecopBoolean':
        return self._restore_on_abort

    @property
    def restore_on_regress(self) -> 'MutableDecopBoolean':
        return self._restore_on_regress

    @property
    def regress_tolerance(self) -> 'MutableDecopInteger':
        return self._regress_tolerance

    @property
    def autosave_actuator_values(self) -> 'MutableDecopBoolean':
        return self._autosave_actuator_values

    def start_optimization(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization', input_stream=None, output_type=None, return_type=int)


class ScbOptInput:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_calibrated = DecopReal(client, name + ':value-calibrated')

    @property
    def value_calibrated(self) -> 'DecopReal':
        return self._value_calibrated


class ServoControlServos:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._probe1_hor = ServoControlServo(client, name + ':probe1-hor')
        self._probe1_vert = ServoControlServo(client, name + ':probe1-vert')
        self._ta1_hor = ServoControlServo(client, name + ':ta1-hor')
        self._ta1_vert = ServoControlServo(client, name + ':ta1-vert')
        self._ta2_hor = ServoControlServo(client, name + ':ta2-hor')
        self._ta2_vert = ServoControlServo(client, name + ':ta2-vert')
        self._fiber1_hor = ServoControlServo(client, name + ':fiber1-hor')
        self._fiber1_vert = ServoControlServo(client, name + ':fiber1-vert')

    @property
    def probe1_hor(self) -> 'ServoControlServo':
        return self._probe1_hor

    @property
    def probe1_vert(self) -> 'ServoControlServo':
        return self._probe1_vert

    @property
    def ta1_hor(self) -> 'ServoControlServo':
        return self._ta1_hor

    @property
    def ta1_vert(self) -> 'ServoControlServo':
        return self._ta1_vert

    @property
    def ta2_hor(self) -> 'ServoControlServo':
        return self._ta2_hor

    @property
    def ta2_vert(self) -> 'ServoControlServo':
        return self._ta2_vert

    @property
    def fiber1_hor(self) -> 'ServoControlServo':
        return self._fiber1_hor

    @property
    def fiber1_vert(self) -> 'ServoControlServo':
        return self._fiber1_vert

    def center_probe_servos(self) -> None:
        self.__client.exec(self.__name + ':center-probe-servos', input_stream=None, output_type=None, return_type=None)

    def center_ta_servos(self) -> None:
        self.__client.exec(self.__name + ':center-ta-servos', input_stream=None, output_type=None, return_type=None)

    def center_fiber_servos(self) -> None:
        self.__client.exec(self.__name + ':center-fiber-servos', input_stream=None, output_type=None, return_type=None)

    def center_all_servos(self) -> None:
        self.__client.exec(self.__name + ':center-all-servos', input_stream=None, output_type=None, return_type=None)


class ServoControlServo:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._display_name = DecopString(client, name + ':display-name')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._value = MutableDecopInteger(client, name + ':value')

    @property
    def display_name(self) -> 'DecopString':
        return self._display_name

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def value(self) -> 'MutableDecopInteger':
        return self._value

    def center_servo(self) -> None:
        self.__client.exec(self.__name + ':center-servo', input_stream=None, output_type=None, return_type=None)


class DlMotorStepper:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._position_set = MutableDecopInteger(client, name + ':position-set')
        self._position_act = DecopInteger(client, name + ':position-act')
        self._position_min = DecopInteger(client, name + ':position-min')
        self._position_max = DecopInteger(client, name + ':position-max')
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._wavelength_set = MutableDecopReal(client, name + ':wavelength-set')
        self._wavelength_act = DecopReal(client, name + ':wavelength-act')
        self._scan = DlMotorScan(client, name + ':scan')
        self._calibration = DlMotorCalibration(client, name + ':calibration')
        self._cycle_count = DecopInteger(client, name + ':cycle-count')

    @property
    def position_set(self) -> 'MutableDecopInteger':
        return self._position_set

    @property
    def position_act(self) -> 'DecopInteger':
        return self._position_act

    @property
    def position_min(self) -> 'DecopInteger':
        return self._position_min

    @property
    def position_max(self) -> 'DecopInteger':
        return self._position_max

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def wavelength_set(self) -> 'MutableDecopReal':
        return self._wavelength_set

    @property
    def wavelength_act(self) -> 'DecopReal':
        return self._wavelength_act

    @property
    def scan(self) -> 'DlMotorScan':
        return self._scan

    @property
    def calibration(self) -> 'DlMotorCalibration':
        return self._calibration

    @property
    def cycle_count(self) -> 'DecopInteger':
        return self._cycle_count

    def perform_referencing(self) -> None:
        self.__client.exec(self.__name + ':perform-referencing', input_stream=None, output_type=None, return_type=None)

    def reset_cycles(self) -> None:
        self.__client.exec(self.__name + ':reset-cycles', input_stream=None, output_type=None, return_type=None)


class DlMotorScan:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._speed = MutableDecopReal(client, name + ':speed')
        self._speed_max = DecopReal(client, name + ':speed-max')
        self._shape = MutableDecopInteger(client, name + ':shape')
        self._scan_begin = MutableDecopReal(client, name + ':scan-begin')
        self._scan_end = MutableDecopReal(client, name + ':scan-end')
        self._progress = DecopInteger(client, name + ':progress')
        self._remaining_time = DecopInteger(client, name + ':remaining-time')
        self._continuous_mode = MutableDecopBoolean(client, name + ':continuous-mode')
        self._threshold_trigger = DlMotorThresholdTrigger(client, name + ':threshold-trigger')

    @property
    def speed(self) -> 'MutableDecopReal':
        return self._speed

    @property
    def speed_max(self) -> 'DecopReal':
        return self._speed_max

    @property
    def shape(self) -> 'MutableDecopInteger':
        return self._shape

    @property
    def scan_begin(self) -> 'MutableDecopReal':
        return self._scan_begin

    @property
    def scan_end(self) -> 'MutableDecopReal':
        return self._scan_end

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def remaining_time(self) -> 'DecopInteger':
        return self._remaining_time

    @property
    def continuous_mode(self) -> 'MutableDecopBoolean':
        return self._continuous_mode

    @property
    def threshold_trigger(self) -> 'DlMotorThresholdTrigger':
        return self._threshold_trigger

    def start(self) -> None:
        self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    def stop(self) -> None:
        self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)

    def pause(self) -> None:
        self.__client.exec(self.__name + ':pause', input_stream=None, output_type=None, return_type=None)

    def continue_(self) -> None:
        self.__client.exec(self.__name + ':continue', input_stream=None, output_type=None, return_type=None)


class DlMotorThresholdTrigger:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._threshold = MutableDecopReal(client, name + ':threshold')

    @property
    def threshold(self) -> 'MutableDecopReal':
        return self._threshold


class DlMotorCalibration:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._fit_a = DecopReal(client, name + ':fit-a')
        self._fit_b = DecopReal(client, name + ':fit-b')
        self._fit_c = DecopReal(client, name + ':fit-c')
        self._backlash = MutableDecopInteger(client, name + ':backlash')
        self._wavelength_min = DecopReal(client, name + ':wavelength-min')
        self._wavelength_max = DecopReal(client, name + ':wavelength-max')

    @property
    def fit_a(self) -> 'DecopReal':
        return self._fit_a

    @property
    def fit_b(self) -> 'DecopReal':
        return self._fit_b

    @property
    def fit_c(self) -> 'DecopReal':
        return self._fit_c

    @property
    def backlash(self) -> 'MutableDecopInteger':
        return self._backlash

    @property
    def wavelength_min(self) -> 'DecopReal':
        return self._wavelength_min

    @property
    def wavelength_max(self) -> 'DecopReal':
        return self._wavelength_max

    def set(self, fit_a: float, fit_b: float, fit_c: float, wavelength_min: float, wavelength_max: float) -> None:
        assert isinstance(fit_a, float), f"expected type 'float' for parameter 'fit_a', got '{type(fit_a)}'"
        assert isinstance(fit_b, float), f"expected type 'float' for parameter 'fit_b', got '{type(fit_b)}'"
        assert isinstance(fit_c, float), f"expected type 'float' for parameter 'fit_c', got '{type(fit_c)}'"
        assert isinstance(wavelength_min, float), f"expected type 'float' for parameter 'wavelength_min', got '{type(wavelength_min)}'"
        assert isinstance(wavelength_max, float), f"expected type 'float' for parameter 'wavelength_max', got '{type(wavelength_max)}'"
        self.__client.exec(self.__name + ':set', fit_a, fit_b, fit_c, wavelength_min, wavelength_max, input_stream=None, output_type=None, return_type=None)


class LhFactory:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._wavelength = MutableDecopReal(client, name + ':wavelength')
        self._threshold_current = MutableDecopReal(client, name + ':threshold-current')
        self._power = MutableDecopReal(client, name + ':power')
        self._cc = LhFactoryCc(client, name + ':cc')
        self._tc = TcFactorySettings(client, name + ':tc')
        self._pc = DlPcFactorySettings(client, name + ':pc')
        self._eom = PcFactorySettings(client, name + ':eom')
        self._pd = DlPdFactorySettings(client, name + ':pd')
        self._motor = DlMotorFactorySettings(client, name + ':motor')
        self._latest_service = DecopString(client, name + ':latest-service')
        self._last_modified = DecopString(client, name + ':last-modified')
        self._modified = DecopBoolean(client, name + ':modified')

    @property
    def wavelength(self) -> 'MutableDecopReal':
        return self._wavelength

    @property
    def threshold_current(self) -> 'MutableDecopReal':
        return self._threshold_current

    @property
    def power(self) -> 'MutableDecopReal':
        return self._power

    @property
    def cc(self) -> 'LhFactoryCc':
        return self._cc

    @property
    def tc(self) -> 'TcFactorySettings':
        return self._tc

    @property
    def pc(self) -> 'DlPcFactorySettings':
        return self._pc

    @property
    def eom(self) -> 'PcFactorySettings':
        return self._eom

    @property
    def pd(self) -> 'DlPdFactorySettings':
        return self._pd

    @property
    def motor(self) -> 'DlMotorFactorySettings':
        return self._motor

    @property
    def latest_service(self) -> 'DecopString':
        return self._latest_service

    @property
    def last_modified(self) -> 'DecopString':
        return self._last_modified

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)

    def update_service_date(self) -> None:
        self.__client.exec(self.__name + ':update-service-date', input_stream=None, output_type=None, return_type=None)


class LhFactoryCc:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._current_set = MutableDecopReal(client, name + ':current-set')
        self._current_clip = MutableDecopReal(client, name + ':current-clip')
        self._current_clip_tuning = MutableDecopReal(client, name + ':current-clip-tuning')
        self._current_clip_modified = DecopBoolean(client, name + ':current-clip-modified')
        self._current_clip_last_modified = DecopString(client, name + ':current-clip-last-modified')
        self._voltage_clip = MutableDecopReal(client, name + ':voltage-clip')
        self._positive_polarity = MutableDecopBoolean(client, name + ':positive-polarity')
        self._snubber = MutableDecopBoolean(client, name + ':snubber')

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def current_set(self) -> 'MutableDecopReal':
        return self._current_set

    @property
    def current_clip(self) -> 'MutableDecopReal':
        return self._current_clip

    @property
    def current_clip_tuning(self) -> 'MutableDecopReal':
        return self._current_clip_tuning

    @property
    def current_clip_modified(self) -> 'DecopBoolean':
        return self._current_clip_modified

    @property
    def current_clip_last_modified(self) -> 'DecopString':
        return self._current_clip_last_modified

    @property
    def voltage_clip(self) -> 'MutableDecopReal':
        return self._voltage_clip

    @property
    def positive_polarity(self) -> 'MutableDecopBoolean':
        return self._positive_polarity

    @property
    def snubber(self) -> 'MutableDecopBoolean':
        return self._snubber


class TcFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_min = MutableDecopReal(client, name + ':temp-min')
        self._temp_max = MutableDecopReal(client, name + ':temp-max')
        self._temp_set = MutableDecopReal(client, name + ':temp-set')
        self._temp_roc_enabled = MutableDecopBoolean(client, name + ':temp-roc-enabled')
        self._temp_roc_limit = MutableDecopReal(client, name + ':temp-roc-limit')
        self._current_max = MutableDecopReal(client, name + ':current-max')
        self._current_min = MutableDecopReal(client, name + ':current-min')
        self._p_gain = MutableDecopReal(client, name + ':p-gain')
        self._i_gain = MutableDecopReal(client, name + ':i-gain')
        self._d_gain = MutableDecopReal(client, name + ':d-gain')
        self._c_gain = MutableDecopReal(client, name + ':c-gain')
        self._ok_tolerance = MutableDecopReal(client, name + ':ok-tolerance')
        self._ok_time = MutableDecopReal(client, name + ':ok-time')
        self._timeout = MutableDecopInteger(client, name + ':timeout')
        self._power_source = MutableDecopInteger(client, name + ':power-source')
        self._ntc_series_resistance = MutableDecopReal(client, name + ':ntc-series-resistance')
        self._ntc_parallel_resistance = MutableDecopReal(client, name + ':ntc-parallel-resistance')

    @property
    def temp_min(self) -> 'MutableDecopReal':
        return self._temp_min

    @property
    def temp_max(self) -> 'MutableDecopReal':
        return self._temp_max

    @property
    def temp_set(self) -> 'MutableDecopReal':
        return self._temp_set

    @property
    def temp_roc_enabled(self) -> 'MutableDecopBoolean':
        return self._temp_roc_enabled

    @property
    def temp_roc_limit(self) -> 'MutableDecopReal':
        return self._temp_roc_limit

    @property
    def current_max(self) -> 'MutableDecopReal':
        return self._current_max

    @property
    def current_min(self) -> 'MutableDecopReal':
        return self._current_min

    @property
    def p_gain(self) -> 'MutableDecopReal':
        return self._p_gain

    @property
    def i_gain(self) -> 'MutableDecopReal':
        return self._i_gain

    @property
    def d_gain(self) -> 'MutableDecopReal':
        return self._d_gain

    @property
    def c_gain(self) -> 'MutableDecopReal':
        return self._c_gain

    @property
    def ok_tolerance(self) -> 'MutableDecopReal':
        return self._ok_tolerance

    @property
    def ok_time(self) -> 'MutableDecopReal':
        return self._ok_time

    @property
    def timeout(self) -> 'MutableDecopInteger':
        return self._timeout

    @property
    def power_source(self) -> 'MutableDecopInteger':
        return self._power_source

    @property
    def ntc_series_resistance(self) -> 'MutableDecopReal':
        return self._ntc_series_resistance

    @property
    def ntc_parallel_resistance(self) -> 'MutableDecopReal':
        return self._ntc_parallel_resistance


class DlPcFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._capacitance = MutableDecopReal(client, name + ':capacitance')
        self._scan_offset = MutableDecopReal(client, name + ':scan-offset')
        self._scan_amplitude = MutableDecopReal(client, name + ':scan-amplitude')
        self._slew_rate = MutableDecopReal(client, name + ':slew-rate')
        self._slew_rate_enabled = MutableDecopBoolean(client, name + ':slew-rate-enabled')
        self._pressure_compensation_factor = MutableDecopReal(client, name + ':pressure-compensation-factor')

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def capacitance(self) -> 'MutableDecopReal':
        return self._capacitance

    @property
    def scan_offset(self) -> 'MutableDecopReal':
        return self._scan_offset

    @property
    def scan_amplitude(self) -> 'MutableDecopReal':
        return self._scan_amplitude

    @property
    def slew_rate(self) -> 'MutableDecopReal':
        return self._slew_rate

    @property
    def slew_rate_enabled(self) -> 'MutableDecopBoolean':
        return self._slew_rate_enabled

    @property
    def pressure_compensation_factor(self) -> 'MutableDecopReal':
        return self._pressure_compensation_factor


class PcFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._capacitance = MutableDecopReal(client, name + ':capacitance')
        self._scan_offset = MutableDecopReal(client, name + ':scan-offset')

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def capacitance(self) -> 'MutableDecopReal':
        return self._capacitance

    @property
    def scan_offset(self) -> 'MutableDecopReal':
        return self._scan_offset


class DlPdFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._seed = PdCalFactorySettings(client, name + ':seed')

    @property
    def seed(self) -> 'PdCalFactorySettings':
        return self._seed


class PdCalFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class DlMotorFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._position_min = DecopInteger(client, name + ':position-min')
        self._position_max = DecopInteger(client, name + ':position-max')
        self._wavelength_set = MutableDecopReal(client, name + ':wavelength-set')
        self._speed_max_raw = DecopInteger(client, name + ':speed-max-raw')
        self._calibration = DlMotorCalibrationFactorySettings(client, name + ':calibration')

    @property
    def position_min(self) -> 'DecopInteger':
        return self._position_min

    @property
    def position_max(self) -> 'DecopInteger':
        return self._position_max

    @property
    def wavelength_set(self) -> 'MutableDecopReal':
        return self._wavelength_set

    @property
    def speed_max_raw(self) -> 'DecopInteger':
        return self._speed_max_raw

    @property
    def calibration(self) -> 'DlMotorCalibrationFactorySettings':
        return self._calibration


class DlMotorCalibrationFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._fit_a = MutableDecopReal(client, name + ':fit-a')
        self._fit_b = MutableDecopReal(client, name + ':fit-b')
        self._fit_c = MutableDecopReal(client, name + ':fit-c')
        self._backlash = MutableDecopInteger(client, name + ':backlash')
        self._inaccuracy = MutableDecopReal(client, name + ':inaccuracy')
        self._wavelength_min = MutableDecopReal(client, name + ':wavelength-min')
        self._wavelength_max = MutableDecopReal(client, name + ':wavelength-max')

    @property
    def fit_a(self) -> 'MutableDecopReal':
        return self._fit_a

    @property
    def fit_b(self) -> 'MutableDecopReal':
        return self._fit_b

    @property
    def fit_c(self) -> 'MutableDecopReal':
        return self._fit_c

    @property
    def backlash(self) -> 'MutableDecopInteger':
        return self._backlash

    @property
    def inaccuracy(self) -> 'MutableDecopReal':
        return self._inaccuracy

    @property
    def wavelength_min(self) -> 'MutableDecopReal':
        return self._wavelength_min

    @property
    def wavelength_max(self) -> 'MutableDecopReal':
        return self._wavelength_max


class CtlT:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._model = DecopString(client, name + ':model')
        self._wavelength_set = MutableDecopReal(client, name + ':wavelength-set')
        self._wavelength_act = DecopReal(client, name + ':wavelength-act')
        self._wavelength_min = DecopReal(client, name + ':wavelength-min')
        self._wavelength_max = DecopReal(client, name + ':wavelength-max')
        self._tuning_current_min = DecopReal(client, name + ':tuning-current-min')
        self._tuning_power_min = DecopReal(client, name + ':tuning-power-min')
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._head_temperature = DecopReal(client, name + ':head-temperature')
        self._optimization = CtlOptimizationT(client, name + ':optimization')
        self._remote_control = CtlRemoteControl(client, name + ':remote-control')
        self._mode_control = CtlModeControl(client, name + ':mode-control')
        self._motor = CtlMotor(client, name + ':motor')
        self._power = CtlPower(client, name + ':power')
        self._factory_settings = CtlFactory(client, name + ':factory-settings')

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def model(self) -> 'DecopString':
        return self._model

    @property
    def wavelength_set(self) -> 'MutableDecopReal':
        return self._wavelength_set

    @property
    def wavelength_act(self) -> 'DecopReal':
        return self._wavelength_act

    @property
    def wavelength_min(self) -> 'DecopReal':
        return self._wavelength_min

    @property
    def wavelength_max(self) -> 'DecopReal':
        return self._wavelength_max

    @property
    def tuning_current_min(self) -> 'DecopReal':
        return self._tuning_current_min

    @property
    def tuning_power_min(self) -> 'DecopReal':
        return self._tuning_power_min

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def head_temperature(self) -> 'DecopReal':
        return self._head_temperature

    @property
    def optimization(self) -> 'CtlOptimizationT':
        return self._optimization

    @property
    def remote_control(self) -> 'CtlRemoteControl':
        return self._remote_control

    @property
    def mode_control(self) -> 'CtlModeControl':
        return self._mode_control

    @property
    def motor(self) -> 'CtlMotor':
        return self._motor

    @property
    def power(self) -> 'CtlPower':
        return self._power

    @property
    def factory_settings(self) -> 'CtlFactory':
        return self._factory_settings


class CtlOptimizationT:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._progress = DecopInteger(client, name + ':progress')

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    def smile(self) -> None:
        self.__client.exec(self.__name + ':smile', input_stream=None, output_type=None, return_type=None)

    def flow(self) -> None:
        self.__client.exec(self.__name + ':flow', input_stream=None, output_type=None, return_type=None)

    def abort(self) -> None:
        self.__client.exec(self.__name + ':abort', input_stream=None, output_type=None, return_type=None)


class CtlRemoteControl:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._factor = MutableDecopReal(client, name + ':factor')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def factor(self) -> 'MutableDecopReal':
        return self._factor

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled


class CtlModeControl:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._loop_enabled = MutableDecopBoolean(client, name + ':loop-enabled')

    @property
    def loop_enabled(self) -> 'MutableDecopBoolean':
        return self._loop_enabled


class CtlMotor:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._position_accuracy_fullstep = MutableDecopInteger(client, name + ':position-accuracy-fullstep')
        self._position_hysteresis_fullstep = MutableDecopInteger(client, name + ':position-hysteresis-fullstep')
        self._position_accuracy_microstep = MutableDecopInteger(client, name + ':position-accuracy-microstep')
        self._position_hysteresis_microstep = MutableDecopInteger(client, name + ':position-hysteresis-microstep')
        self._microsteps = MutableDecopBoolean(client, name + ':microsteps')
        self._power_save_disabled = MutableDecopBoolean(client, name + ':power-save-disabled')

    @property
    def position_accuracy_fullstep(self) -> 'MutableDecopInteger':
        return self._position_accuracy_fullstep

    @property
    def position_hysteresis_fullstep(self) -> 'MutableDecopInteger':
        return self._position_hysteresis_fullstep

    @property
    def position_accuracy_microstep(self) -> 'MutableDecopInteger':
        return self._position_accuracy_microstep

    @property
    def position_hysteresis_microstep(self) -> 'MutableDecopInteger':
        return self._position_hysteresis_microstep

    @property
    def microsteps(self) -> 'MutableDecopBoolean':
        return self._microsteps

    @property
    def power_save_disabled(self) -> 'MutableDecopBoolean':
        return self._power_save_disabled


class CtlPower:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power_act = DecopReal(client, name + ':power-act')

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act


class CtlFactory:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._wavelength_min = DecopReal(client, name + ':wavelength-min')
        self._wavelength_max = DecopReal(client, name + ':wavelength-max')
        self._tuning_current_min = DecopReal(client, name + ':tuning-current-min')
        self._tuning_power_min = DecopReal(client, name + ':tuning-power-min')

    @property
    def wavelength_min(self) -> 'DecopReal':
        return self._wavelength_min

    @property
    def wavelength_max(self) -> 'DecopReal':
        return self._wavelength_max

    @property
    def tuning_current_min(self) -> 'DecopReal':
        return self._tuning_current_min

    @property
    def tuning_power_min(self) -> 'DecopReal':
        return self._tuning_power_min

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)


class LaserAmp:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._legacy = DecopBoolean(client, name + ':legacy')
        self._type = DecopString(client, name + ':type')
        self._version = DecopString(client, name + ':version')
        self._model = DecopString(client, name + ':model')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._fru_serial_number = DecopString(client, name + ':fru-serial-number')
        self._ontime = DecopInteger(client, name + ':ontime')
        self._ontime_txt = DecopString(client, name + ':ontime-txt')
        self._cc = Cc5000Drv(client, name + ':cc')
        self._tc = TcChannel1(client, name + ':tc')
        self._pd = AmpPd(client, name + ':pd')
        self._power_optimization = ScbPowerOptimization(client, name + ':power-optimization')
        self._servo = ServoControlServos(client, name + ':servo')
        self._seed_limits = AmpPower(client, name + ':seed-limits')
        self._output_limits = AmpPower(client, name + ':output-limits')
        self._seedonly_check = AmpSeedonlyCheck(client, name + ':seedonly-check')
        self._factory_settings = AmpFactory(client, name + ':factory-settings')

    @property
    def legacy(self) -> 'DecopBoolean':
        return self._legacy

    @property
    def type(self) -> 'DecopString':
        return self._type

    @property
    def version(self) -> 'DecopString':
        return self._version

    @property
    def model(self) -> 'DecopString':
        return self._model

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def fru_serial_number(self) -> 'DecopString':
        return self._fru_serial_number

    @property
    def ontime(self) -> 'DecopInteger':
        return self._ontime

    @property
    def ontime_txt(self) -> 'DecopString':
        return self._ontime_txt

    @property
    def cc(self) -> 'Cc5000Drv':
        return self._cc

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc

    @property
    def pd(self) -> 'AmpPd':
        return self._pd

    @property
    def power_optimization(self) -> 'ScbPowerOptimization':
        return self._power_optimization

    @property
    def servo(self) -> 'ServoControlServos':
        return self._servo

    @property
    def seed_limits(self) -> 'AmpPower':
        return self._seed_limits

    @property
    def output_limits(self) -> 'AmpPower':
        return self._output_limits

    @property
    def seedonly_check(self) -> 'AmpSeedonlyCheck':
        return self._seedonly_check

    @property
    def factory_settings(self) -> 'AmpFactory':
        return self._factory_settings

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)


class Cc5000Drv:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._variant = DecopString(client, name + ':variant')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._emission = DecopBoolean(client, name + ':emission')
        self._current_set = MutableDecopReal(client, name + ':current-set')
        self._current_offset = MutableDecopReal(client, name + ':current-offset')
        self._output_filter = OutputFilter1(client, name + ':output-filter')
        self._current_act = DecopReal(client, name + ':current-act')
        self._current_clip = MutableDecopReal(client, name + ':current-clip')
        self._current_clip_tuning = DecopReal(client, name + ':current-clip-tuning')
        self._use_current_clip_tuning = MutableDecopBoolean(client, name + ':use-current-clip-tuning')
        self._current_clip_limit = DecopReal(client, name + ':current-clip-limit')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._voltage_out = DecopReal(client, name + ':voltage-out')
        self._voltage_clip = MutableDecopReal(client, name + ':voltage-clip')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._aux = DecopReal(client, name + ':aux')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._forced_off = MutableDecopBoolean(client, name + ':forced-off')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def current_set(self) -> 'MutableDecopReal':
        return self._current_set

    @property
    def current_offset(self) -> 'MutableDecopReal':
        return self._current_offset

    @property
    def output_filter(self) -> 'OutputFilter1':
        return self._output_filter

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def current_clip(self) -> 'MutableDecopReal':
        return self._current_clip

    @property
    def current_clip_tuning(self) -> 'DecopReal':
        return self._current_clip_tuning

    @property
    def use_current_clip_tuning(self) -> 'MutableDecopBoolean':
        return self._use_current_clip_tuning

    @property
    def current_clip_limit(self) -> 'DecopReal':
        return self._current_clip_limit

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def voltage_out(self) -> 'DecopReal':
        return self._voltage_out

    @property
    def voltage_clip(self) -> 'MutableDecopReal':
        return self._voltage_clip

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def aux(self) -> 'DecopReal':
        return self._aux

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def forced_off(self) -> 'MutableDecopBoolean':
        return self._forced_off


class AmpPd:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._seed = PdCal(client, name + ':seed')
        self._seed_probe = ServoControlPdCal(client, name + ':seed-probe')
        self._amp = PdCal(client, name + ':amp')
        self._fiber = ServoControlPdCal(client, name + ':fiber')

    @property
    def seed(self) -> 'PdCal':
        return self._seed

    @property
    def seed_probe(self) -> 'ServoControlPdCal':
        return self._seed_probe

    @property
    def amp(self) -> 'PdCal':
        return self._amp

    @property
    def fiber(self) -> 'ServoControlPdCal':
        return self._fiber


class AmpPower:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power = DecopReal(client, name + ':power')
        self._power_min = MutableDecopReal(client, name + ':power-min')
        self._power_min_warning_delay = MutableDecopReal(client, name + ':power-min-warning-delay')
        self._power_min_shutdown_delay = MutableDecopReal(client, name + ':power-min-shutdown-delay')
        self._power_max = MutableDecopReal(client, name + ':power-max')
        self._power_max_warning_delay = MutableDecopReal(client, name + ':power-max-warning-delay')
        self._power_max_shutdown_delay = MutableDecopReal(client, name + ':power-max-shutdown-delay')
        self._detect_pd_removal = MutableDecopBoolean(client, name + ':detect-pd-removal')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def power_min(self) -> 'MutableDecopReal':
        return self._power_min

    @property
    def power_min_warning_delay(self) -> 'MutableDecopReal':
        return self._power_min_warning_delay

    @property
    def power_min_shutdown_delay(self) -> 'MutableDecopReal':
        return self._power_min_shutdown_delay

    @property
    def power_max(self) -> 'MutableDecopReal':
        return self._power_max

    @property
    def power_max_warning_delay(self) -> 'MutableDecopReal':
        return self._power_max_warning_delay

    @property
    def power_max_shutdown_delay(self) -> 'MutableDecopReal':
        return self._power_max_shutdown_delay

    @property
    def detect_pd_removal(self) -> 'MutableDecopBoolean':
        return self._detect_pd_removal

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class AmpSeedonlyCheck:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._seed = DecopBoolean(client, name + ':seed')
        self._pump = DecopBoolean(client, name + ':pump')
        self._warning_delay = MutableDecopReal(client, name + ':warning-delay')
        self._shutdown_delay = MutableDecopReal(client, name + ':shutdown-delay')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def seed(self) -> 'DecopBoolean':
        return self._seed

    @property
    def pump(self) -> 'DecopBoolean':
        return self._pump

    @property
    def warning_delay(self) -> 'MutableDecopReal':
        return self._warning_delay

    @property
    def shutdown_delay(self) -> 'MutableDecopReal':
        return self._shutdown_delay

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class AmpFactory:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._wavelength = MutableDecopReal(client, name + ':wavelength')
        self._power = MutableDecopReal(client, name + ':power')
        self._cc = AmpFactoryCc(client, name + ':cc')
        self._tc = TcFactorySettings(client, name + ':tc')
        self._pd = AmpPdFactorySettings(client, name + ':pd')
        self._seed_limits = AmpFactoryPower(client, name + ':seed-limits')
        self._output_limits = AmpFactoryPower(client, name + ':output-limits')
        self._seedonly_check = AmpFactorySeedonly(client, name + ':seedonly-check')
        self._latest_service = DecopString(client, name + ':latest-service')
        self._last_modified = DecopString(client, name + ':last-modified')
        self._modified = DecopBoolean(client, name + ':modified')

    @property
    def wavelength(self) -> 'MutableDecopReal':
        return self._wavelength

    @property
    def power(self) -> 'MutableDecopReal':
        return self._power

    @property
    def cc(self) -> 'AmpFactoryCc':
        return self._cc

    @property
    def tc(self) -> 'TcFactorySettings':
        return self._tc

    @property
    def pd(self) -> 'AmpPdFactorySettings':
        return self._pd

    @property
    def seed_limits(self) -> 'AmpFactoryPower':
        return self._seed_limits

    @property
    def output_limits(self) -> 'AmpFactoryPower':
        return self._output_limits

    @property
    def seedonly_check(self) -> 'AmpFactorySeedonly':
        return self._seedonly_check

    @property
    def latest_service(self) -> 'DecopString':
        return self._latest_service

    @property
    def last_modified(self) -> 'DecopString':
        return self._last_modified

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)

    def update_service_date(self) -> None:
        self.__client.exec(self.__name + ':update-service-date', input_stream=None, output_type=None, return_type=None)


class AmpFactoryCc:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._current_set = MutableDecopReal(client, name + ':current-set')
        self._current_clip = MutableDecopReal(client, name + ':current-clip')
        self._current_clip_tuning = MutableDecopReal(client, name + ':current-clip-tuning')
        self._current_clip_modified = DecopBoolean(client, name + ':current-clip-modified')
        self._current_clip_last_modified = DecopString(client, name + ':current-clip-last-modified')
        self._voltage_clip = MutableDecopReal(client, name + ':voltage-clip')

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def current_set(self) -> 'MutableDecopReal':
        return self._current_set

    @property
    def current_clip(self) -> 'MutableDecopReal':
        return self._current_clip

    @property
    def current_clip_tuning(self) -> 'MutableDecopReal':
        return self._current_clip_tuning

    @property
    def current_clip_modified(self) -> 'DecopBoolean':
        return self._current_clip_modified

    @property
    def current_clip_last_modified(self) -> 'DecopString':
        return self._current_clip_last_modified

    @property
    def voltage_clip(self) -> 'MutableDecopReal':
        return self._voltage_clip


class AmpPdFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._seed = PdCalFactorySettings(client, name + ':seed')
        self._amp = PdCalFactorySettings(client, name + ':amp')

    @property
    def seed(self) -> 'PdCalFactorySettings':
        return self._seed

    @property
    def amp(self) -> 'PdCalFactorySettings':
        return self._amp


class AmpFactoryPower:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power_min = MutableDecopReal(client, name + ':power-min')
        self._power_min_warning_delay = MutableDecopReal(client, name + ':power-min-warning-delay')
        self._power_min_shutdown_delay = MutableDecopReal(client, name + ':power-min-shutdown-delay')
        self._power_max = MutableDecopReal(client, name + ':power-max')
        self._power_max_warning_delay = MutableDecopReal(client, name + ':power-max-warning-delay')
        self._power_max_shutdown_delay = MutableDecopReal(client, name + ':power-max-shutdown-delay')

    @property
    def power_min(self) -> 'MutableDecopReal':
        return self._power_min

    @property
    def power_min_warning_delay(self) -> 'MutableDecopReal':
        return self._power_min_warning_delay

    @property
    def power_min_shutdown_delay(self) -> 'MutableDecopReal':
        return self._power_min_shutdown_delay

    @property
    def power_max(self) -> 'MutableDecopReal':
        return self._power_max

    @property
    def power_max_warning_delay(self) -> 'MutableDecopReal':
        return self._power_max_warning_delay

    @property
    def power_max_shutdown_delay(self) -> 'MutableDecopReal':
        return self._power_max_shutdown_delay


class AmpFactorySeedonly:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._warning_delay = MutableDecopReal(client, name + ':warning-delay')
        self._shutdown_delay = MutableDecopReal(client, name + ':shutdown-delay')

    @property
    def warning_delay(self) -> 'MutableDecopReal':
        return self._warning_delay

    @property
    def shutdown_delay(self) -> 'MutableDecopReal':
        return self._shutdown_delay


class Dpss1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._tc_status = DecopInteger(client, name + ':tc-status')
        self._tc_status_txt = DecopString(client, name + ':tc-status-txt')
        self._error_code = DecopInteger(client, name + ':error-code')
        self._error_txt = DecopString(client, name + ':error-txt')
        self._operation_time = DecopReal(client, name + ':operation-time')
        self._power_set = MutableDecopReal(client, name + ':power-set')
        self._power_act = DecopReal(client, name + ':power-act')
        self._power_max = DecopReal(client, name + ':power-max')
        self._power_margin = DecopReal(client, name + ':power-margin')
        self._current_act = DecopReal(client, name + ':current-act')
        self._current_max = DecopReal(client, name + ':current-max')
        self._temperature_control = DpssTemperatureParameters1(client, name + ':temperature-control')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def tc_status(self) -> 'DecopInteger':
        return self._tc_status

    @property
    def tc_status_txt(self) -> 'DecopString':
        return self._tc_status_txt

    @property
    def error_code(self) -> 'DecopInteger':
        return self._error_code

    @property
    def error_txt(self) -> 'DecopString':
        return self._error_txt

    @property
    def operation_time(self) -> 'DecopReal':
        return self._operation_time

    @property
    def power_set(self) -> 'MutableDecopReal':
        return self._power_set

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act

    @property
    def power_max(self) -> 'DecopReal':
        return self._power_max

    @property
    def power_margin(self) -> 'DecopReal':
        return self._power_margin

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def current_max(self) -> 'DecopReal':
        return self._current_max

    @property
    def temperature_control(self) -> 'DpssTemperatureParameters1':
        return self._temperature_control


class DpssTemperatureParameters1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._t1 = DpssTemperatureControlParameters1(client, name + ':t1')
        self._t2 = DpssTemperatureControlParameters1(client, name + ':t2')
        self._t3 = DpssTemperatureControlParameters1(client, name + ':t3')
        self._t4 = DpssTemperatureControlParameters1(client, name + ':t4')
        self._t5 = DpssTemperatureControlParameters1(client, name + ':t5')

    @property
    def t1(self) -> 'DpssTemperatureControlParameters1':
        return self._t1

    @property
    def t2(self) -> 'DpssTemperatureControlParameters1':
        return self._t2

    @property
    def t3(self) -> 'DpssTemperatureControlParameters1':
        return self._t3

    @property
    def t4(self) -> 'DpssTemperatureControlParameters1':
        return self._t4

    @property
    def t5(self) -> 'DpssTemperatureControlParameters1':
        return self._t5


class DpssTemperatureControlParameters1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_act = DecopReal(client, name + ':temp-act')
        self._temp_set = MutableDecopReal(client, name + ':temp-set')
        self._temp_set_min = MutableDecopReal(client, name + ':temp-set-min')
        self._temp_set_max = MutableDecopReal(client, name + ':temp-set-max')
        self._temp_roc_limit = MutableDecopReal(client, name + ':temp-roc-limit')

    @property
    def temp_act(self) -> 'DecopReal':
        return self._temp_act

    @property
    def temp_set(self) -> 'MutableDecopReal':
        return self._temp_set

    @property
    def temp_set_min(self) -> 'MutableDecopReal':
        return self._temp_set_min

    @property
    def temp_set_max(self) -> 'MutableDecopReal':
        return self._temp_set_max

    @property
    def temp_roc_limit(self) -> 'MutableDecopReal':
        return self._temp_roc_limit


class ScanGenerator:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._hold = MutableDecopBoolean(client, name + ':hold')
        self._signal_type = MutableDecopInteger(client, name + ':signal-type')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._phase_shift = MutableDecopReal(client, name + ':phase-shift')
        self._output_channel = MutableDecopInteger(client, name + ':output-channel')
        self._unit = DecopString(client, name + ':unit')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._offset = MutableDecopReal(client, name + ':offset')
        self._start = MutableDecopReal(client, name + ':start')
        self._end = MutableDecopReal(client, name + ':end')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def hold(self) -> 'MutableDecopBoolean':
        return self._hold

    @property
    def signal_type(self) -> 'MutableDecopInteger':
        return self._signal_type

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def phase_shift(self) -> 'MutableDecopReal':
        return self._phase_shift

    @property
    def output_channel(self) -> 'MutableDecopInteger':
        return self._output_channel

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def offset(self) -> 'MutableDecopReal':
        return self._offset

    @property
    def start(self) -> 'MutableDecopReal':
        return self._start

    @property
    def end(self) -> 'MutableDecopReal':
        return self._end


class WideScan:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._output_channel = MutableDecopInteger(client, name + ':output-channel')
        self._scan_begin = MutableDecopReal(client, name + ':scan-begin')
        self._scan_end = MutableDecopReal(client, name + ':scan-end')
        self._continuous_mode = MutableDecopBoolean(client, name + ':continuous-mode')
        self._shape = MutableDecopInteger(client, name + ':shape')
        self._offset = MutableDecopReal(client, name + ':offset')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._speed = MutableDecopReal(client, name + ':speed')
        self._speed_min = DecopReal(client, name + ':speed-min')
        self._speed_max = DecopReal(client, name + ':speed-max')
        self._duration = MutableDecopReal(client, name + ':duration')
        self._value_set = MutableDecopReal(client, name + ':value-set')
        self._value_act = DecopReal(client, name + ':value-act')
        self._value_unit = DecopString(client, name + ':value-unit')
        self._recorder_stepsize_set = MutableDecopReal(client, name + ':recorder-stepsize-set')
        self._recorder_stepsize = DecopReal(client, name + ':recorder-stepsize')
        self._recorder_sample_count = DecopInteger(client, name + ':recorder-sample-count')
        self._recorder_sampling_rate = DecopReal(client, name + ':recorder-sampling-rate')
        self._recorder_sampling_interval = DecopReal(client, name + ':recorder-sampling-interval')
        self._progress = DecopInteger(client, name + ':progress')
        self._remaining_time = DecopInteger(client, name + ':remaining-time')
        self._trigger = WideScanTrigger(client, name + ':trigger')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def output_channel(self) -> 'MutableDecopInteger':
        return self._output_channel

    @property
    def scan_begin(self) -> 'MutableDecopReal':
        return self._scan_begin

    @property
    def scan_end(self) -> 'MutableDecopReal':
        return self._scan_end

    @property
    def continuous_mode(self) -> 'MutableDecopBoolean':
        return self._continuous_mode

    @property
    def shape(self) -> 'MutableDecopInteger':
        return self._shape

    @property
    def offset(self) -> 'MutableDecopReal':
        return self._offset

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def speed(self) -> 'MutableDecopReal':
        return self._speed

    @property
    def speed_min(self) -> 'DecopReal':
        return self._speed_min

    @property
    def speed_max(self) -> 'DecopReal':
        return self._speed_max

    @property
    def duration(self) -> 'MutableDecopReal':
        return self._duration

    @property
    def value_set(self) -> 'MutableDecopReal':
        return self._value_set

    @property
    def value_act(self) -> 'DecopReal':
        return self._value_act

    @property
    def value_unit(self) -> 'DecopString':
        return self._value_unit

    @property
    def recorder_stepsize_set(self) -> 'MutableDecopReal':
        return self._recorder_stepsize_set

    @property
    def recorder_stepsize(self) -> 'DecopReal':
        return self._recorder_stepsize

    @property
    def recorder_sample_count(self) -> 'DecopInteger':
        return self._recorder_sample_count

    @property
    def recorder_sampling_rate(self) -> 'DecopReal':
        return self._recorder_sampling_rate

    @property
    def recorder_sampling_interval(self) -> 'DecopReal':
        return self._recorder_sampling_interval

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def remaining_time(self) -> 'DecopInteger':
        return self._remaining_time

    @property
    def trigger(self) -> 'WideScanTrigger':
        return self._trigger

    def start(self) -> None:
        self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    def stop(self) -> None:
        self.__client.exec(self.__name + ':stop', input_stream=None, output_type=None, return_type=None)

    def set_output_to_zoom_offset(self) -> None:
        self.__client.exec(self.__name + ':set-output-to-zoom-offset', input_stream=None, output_type=None, return_type=None)

    def set_scan_range_to_zoom_range(self) -> None:
        self.__client.exec(self.__name + ':set-scan-range-to-zoom-range', input_stream=None, output_type=None, return_type=None)

    def set_zoom_range_to_scan_range(self) -> None:
        self.__client.exec(self.__name + ':set-zoom-range-to-scan-range', input_stream=None, output_type=None, return_type=None)


class WideScanTrigger:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_enabled = MutableDecopBoolean(client, name + ':input-enabled')
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._output_enabled = MutableDecopBoolean(client, name + ':output-enabled')
        self._output_channel = MutableDecopInteger(client, name + ':output-channel')
        self._output_threshold = MutableDecopReal(client, name + ':output-threshold')

    @property
    def input_enabled(self) -> 'MutableDecopBoolean':
        return self._input_enabled

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def output_enabled(self) -> 'MutableDecopBoolean':
        return self._output_enabled

    @property
    def output_channel(self) -> 'MutableDecopInteger':
        return self._output_channel

    @property
    def output_threshold(self) -> 'MutableDecopReal':
        return self._output_threshold


class ScopeT:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._variant = MutableDecopInteger(client, name + ':variant')
        self._update_rate = MutableDecopInteger(client, name + ':update-rate')
        self._channel1 = ScopeChannelT(client, name + ':channel1')
        self._channel2 = ScopeChannelT(client, name + ':channel2')
        self._channelx = ScopeXAxisT(client, name + ':channelx')
        self._timescale = MutableDecopReal(client, name + ':timescale')
        self._data = DecopBinary(client, name + ':data')

    @property
    def variant(self) -> 'MutableDecopInteger':
        return self._variant

    @property
    def update_rate(self) -> 'MutableDecopInteger':
        return self._update_rate

    @property
    def channel1(self) -> 'ScopeChannelT':
        return self._channel1

    @property
    def channel2(self) -> 'ScopeChannelT':
        return self._channel2

    @property
    def channelx(self) -> 'ScopeXAxisT':
        return self._channelx

    @property
    def timescale(self) -> 'MutableDecopReal':
        return self._timescale

    @property
    def data(self) -> 'DecopBinary':
        return self._data


class ScopeChannelT:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class ScopeXAxisT:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._xy_signal = MutableDecopInteger(client, name + ':xy-signal')
        self._scope_timescale = MutableDecopReal(client, name + ':scope-timescale')
        self._spectrum_range = MutableDecopReal(client, name + ':spectrum-range')
        self._spectrum_omit_dc = MutableDecopBoolean(client, name + ':spectrum-omit-dc')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def xy_signal(self) -> 'MutableDecopInteger':
        return self._xy_signal

    @property
    def scope_timescale(self) -> 'MutableDecopReal':
        return self._scope_timescale

    @property
    def spectrum_range(self) -> 'MutableDecopReal':
        return self._spectrum_range

    @property
    def spectrum_omit_dc(self) -> 'MutableDecopBoolean':
        return self._spectrum_omit_dc

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class Recorder:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._trigger_mode = MutableDecopInteger(client, name + ':trigger-mode')
        self._inputs = RecorderInputChannels(client, name + ':inputs')
        self._recording_mode = MutableDecopInteger(client, name + ':recording-mode')
        self._recording_time = MutableDecopReal(client, name + ':recording-time')
        self._sample_count_set = MutableDecopInteger(client, name + ':sample-count-set')
        self._sample_count = DecopInteger(client, name + ':sample-count')
        self._sampling_interval = DecopReal(client, name + ':sampling-interval')
        self._sampling_rate = DecopReal(client, name + ':sampling-rate')
        self._memory_size = DecopInteger(client, name + ':memory-size')
        self._data = RecorderData(client, name + ':data')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def trigger_mode(self) -> 'MutableDecopInteger':
        return self._trigger_mode

    @property
    def inputs(self) -> 'RecorderInputChannels':
        return self._inputs

    @property
    def recording_mode(self) -> 'MutableDecopInteger':
        return self._recording_mode

    @property
    def recording_time(self) -> 'MutableDecopReal':
        return self._recording_time

    @property
    def sample_count_set(self) -> 'MutableDecopInteger':
        return self._sample_count_set

    @property
    def sample_count(self) -> 'DecopInteger':
        return self._sample_count

    @property
    def sampling_interval(self) -> 'DecopReal':
        return self._sampling_interval

    @property
    def sampling_rate(self) -> 'DecopReal':
        return self._sampling_rate

    @property
    def memory_size(self) -> 'DecopInteger':
        return self._memory_size

    @property
    def data(self) -> 'RecorderData':
        return self._data


class RecorderInputChannels:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._channel1 = RecorderInputChannel(client, name + ':channel1')
        self._channel2 = RecorderInputChannel(client, name + ':channel2')
        self._channelx = RecorderInputChannelx(client, name + ':channelx')

    @property
    def channel1(self) -> 'RecorderInputChannel':
        return self._channel1

    @property
    def channel2(self) -> 'RecorderInputChannel':
        return self._channel2

    @property
    def channelx(self) -> 'RecorderInputChannelx':
        return self._channelx


class RecorderInputChannel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._low_pass_filter = RecorderLowPassFilter(client, name + ':low-pass-filter')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def low_pass_filter(self) -> 'RecorderLowPassFilter':
        return self._low_pass_filter


class RecorderLowPassFilter:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._cut_off_frequency = MutableDecopReal(client, name + ':cut-off-frequency')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def cut_off_frequency(self) -> 'MutableDecopReal':
        return self._cut_off_frequency


class RecorderInputChannelx:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal


class RecorderData:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._channel1 = RecorderDataChannel(client, name + ':channel1')
        self._channel2 = RecorderDataChannel(client, name + ':channel2')
        self._channelx = RecorderDataChannel(client, name + ':channelx')
        self._zoom_data = DecopBinary(client, name + ':zoom-data')
        self._zoom_offset = MutableDecopReal(client, name + ':zoom-offset')
        self._zoom_amplitude = MutableDecopReal(client, name + ':zoom-amplitude')
        self._recorded_sampling_interval = DecopReal(client, name + ':recorded-sampling-interval')
        self._recorded_sample_count = DecopInteger(client, name + ':recorded-sample-count')
        self._last_recorded_sample = DecopInteger(client, name + ':last-recorded-sample')
        self._last_valid_sample = DecopInteger(client, name + ':last-valid-sample')

    @property
    def channel1(self) -> 'RecorderDataChannel':
        return self._channel1

    @property
    def channel2(self) -> 'RecorderDataChannel':
        return self._channel2

    @property
    def channelx(self) -> 'RecorderDataChannel':
        return self._channelx

    @property
    def zoom_data(self) -> 'DecopBinary':
        return self._zoom_data

    @property
    def zoom_offset(self) -> 'MutableDecopReal':
        return self._zoom_offset

    @property
    def zoom_amplitude(self) -> 'MutableDecopReal':
        return self._zoom_amplitude

    @property
    def recorded_sampling_interval(self) -> 'DecopReal':
        return self._recorded_sampling_interval

    @property
    def recorded_sample_count(self) -> 'DecopInteger':
        return self._recorded_sample_count

    @property
    def last_recorded_sample(self) -> 'DecopInteger':
        return self._last_recorded_sample

    @property
    def last_valid_sample(self) -> 'DecopInteger':
        return self._last_valid_sample

    def zoom_out(self) -> None:
        self.__client.exec(self.__name + ':zoom-out', input_stream=None, output_type=None, return_type=None)

    def get_data(self, start_index: int, count: int) -> bytes:
        assert isinstance(start_index, int), f"expected type 'int' for parameter 'start_index', got '{type(start_index)}'"
        assert isinstance(count, int), f"expected type 'int' for parameter 'count', got '{type(count)}'"
        return self.__client.exec(self.__name + ':get-data', start_index, count, input_stream=None, output_type=None, return_type=bytes)

    def show_data(self, start_index: int, count: int) -> None:
        assert isinstance(start_index, int), f"expected type 'int' for parameter 'start_index', got '{type(start_index)}'"
        assert isinstance(count, int), f"expected type 'int' for parameter 'count', got '{type(count)}'"
        self.__client.exec(self.__name + ':show-data', start_index, count, input_stream=None, output_type=None, return_type=None)


class RecorderDataChannel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = DecopInteger(client, name + ':signal')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def signal(self) -> 'DecopInteger':
        return self._signal

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class Nlo:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._servo = NloLaserHeadServos(client, name + ':servo')
        self._pd = NloPhotoDiodes(client, name + ':pd')
        self._power_optimization = NloPowerOptimization(client, name + ':power-optimization')
        self._auto_nlo = AutoNlo(client, name + ':auto-nlo')
        self._shg = Shg(client, name + ':shg')
        self._fhg = Fhg(client, name + ':fhg')
        self._opo = Opo(client, name + ':opo')
        self._ssw_ver = DecopString(client, name + ':ssw-ver')

    @property
    def servo(self) -> 'NloLaserHeadServos':
        return self._servo

    @property
    def pd(self) -> 'NloPhotoDiodes':
        return self._pd

    @property
    def power_optimization(self) -> 'NloPowerOptimization':
        return self._power_optimization

    @property
    def auto_nlo(self) -> 'AutoNlo':
        return self._auto_nlo

    @property
    def shg(self) -> 'Shg':
        return self._shg

    @property
    def fhg(self) -> 'Fhg':
        return self._fhg

    @property
    def opo(self) -> 'Opo':
        return self._opo

    @property
    def ssw_ver(self) -> 'DecopString':
        return self._ssw_ver


class NloLaserHeadServos:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ta1_hor = NloLaserHeadServoPwm1(client, name + ':ta1-hor')
        self._ta1_vert = NloLaserHeadServoPwm1(client, name + ':ta1-vert')
        self._ta2_hor = NloLaserHeadServoPwm1(client, name + ':ta2-hor')
        self._ta2_vert = NloLaserHeadServoPwm1(client, name + ':ta2-vert')
        self._shg1_hor = NloLaserHeadServoPwm1(client, name + ':shg1-hor')
        self._shg1_vert = NloLaserHeadServoPwm1(client, name + ':shg1-vert')
        self._shg2_hor = NloLaserHeadServoPwm1(client, name + ':shg2-hor')
        self._shg2_vert = NloLaserHeadServoPwm1(client, name + ':shg2-vert')
        self._fhg1_hor = NloLaserHeadServoPwm1(client, name + ':fhg1-hor')
        self._fhg1_vert = NloLaserHeadServoPwm1(client, name + ':fhg1-vert')
        self._fhg2_hor = NloLaserHeadServoPwm1(client, name + ':fhg2-hor')
        self._fhg2_vert = NloLaserHeadServoPwm1(client, name + ':fhg2-vert')
        self._fiber1_hor = NloLaserHeadServoPwm1(client, name + ':fiber1-hor')
        self._fiber1_vert = NloLaserHeadServoPwm1(client, name + ':fiber1-vert')
        self._fiber2_hor = NloLaserHeadServoPwm1(client, name + ':fiber2-hor')
        self._fiber2_vert = NloLaserHeadServoPwm1(client, name + ':fiber2-vert')
        self._uv_outcpl = NloLaserHeadServoPwm1(client, name + ':uv-outcpl')
        self._uv_cryst = NloLaserHeadServoPwm1(client, name + ':uv-cryst')
        self._uv_lens = NloLaserHeadServoPwm1(client, name + ':uv-lens')
        self._comp_hor = NloLaserHeadServoPwm1(client, name + ':comp-hor')
        self._comp_vert = NloLaserHeadServoPwm1(client, name + ':comp-vert')
        self._etalon = NloLaserHeadServoPwm1(client, name + ':etalon')

    @property
    def ta1_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._ta1_hor

    @property
    def ta1_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._ta1_vert

    @property
    def ta2_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._ta2_hor

    @property
    def ta2_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._ta2_vert

    @property
    def shg1_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._shg1_hor

    @property
    def shg1_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._shg1_vert

    @property
    def shg2_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._shg2_hor

    @property
    def shg2_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._shg2_vert

    @property
    def fhg1_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._fhg1_hor

    @property
    def fhg1_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._fhg1_vert

    @property
    def fhg2_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._fhg2_hor

    @property
    def fhg2_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._fhg2_vert

    @property
    def fiber1_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._fiber1_hor

    @property
    def fiber1_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._fiber1_vert

    @property
    def fiber2_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._fiber2_hor

    @property
    def fiber2_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._fiber2_vert

    @property
    def uv_outcpl(self) -> 'NloLaserHeadServoPwm1':
        return self._uv_outcpl

    @property
    def uv_cryst(self) -> 'NloLaserHeadServoPwm1':
        return self._uv_cryst

    @property
    def uv_lens(self) -> 'NloLaserHeadServoPwm1':
        return self._uv_lens

    @property
    def comp_hor(self) -> 'NloLaserHeadServoPwm1':
        return self._comp_hor

    @property
    def comp_vert(self) -> 'NloLaserHeadServoPwm1':
        return self._comp_vert

    @property
    def etalon(self) -> 'NloLaserHeadServoPwm1':
        return self._etalon

    def center_ta_servos(self) -> None:
        self.__client.exec(self.__name + ':center-ta-servos', input_stream=None, output_type=None, return_type=None)

    def center_shg_servos(self) -> None:
        self.__client.exec(self.__name + ':center-shg-servos', input_stream=None, output_type=None, return_type=None)

    def center_fhg_servos(self) -> None:
        self.__client.exec(self.__name + ':center-fhg-servos', input_stream=None, output_type=None, return_type=None)

    def center_fiber_servos(self) -> None:
        self.__client.exec(self.__name + ':center-fiber-servos', input_stream=None, output_type=None, return_type=None)

    def center_all_servos(self) -> None:
        self.__client.exec(self.__name + ':center-all-servos', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadServoPwm1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._display_name = DecopString(client, name + ':display-name')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._value = MutableDecopInteger(client, name + ':value')

    @property
    def display_name(self) -> 'DecopString':
        return self._display_name

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def value(self) -> 'MutableDecopInteger':
        return self._value

    def center_servo(self) -> None:
        self.__client.exec(self.__name + ':center-servo', input_stream=None, output_type=None, return_type=None)


class NloPhotoDiodes:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._dl = NloLaserHeadNloPhotodiode1(client, name + ':dl')
        self._amp = NloLaserHeadNloPhotodiode1(client, name + ':amp')
        self._fiber = NloLaserHeadNloPhotodiode1(client, name + ':fiber')
        self._shg = NloLaserHeadNloPhotodiode1(client, name + ':shg')
        self._shg_input = PdCal(client, name + ':shg-input')
        self._shg_int = NloLaserHeadNloDigilockPhotodiode1(client, name + ':shg-int')
        self._shg_pdh_dc = NloLaserHeadNloDigilockPhotodiode1(client, name + ':shg-pdh-dc')
        self._shg_pdh_rf = NloLaserHeadNloPdhPhotodiode1(client, name + ':shg-pdh-rf')
        self._fhg = NloLaserHeadNloPhotodiode1(client, name + ':fhg')
        self._fhg_int = NloLaserHeadNloDigilockPhotodiode1(client, name + ':fhg-int')
        self._fhg_pdh_dc = NloLaserHeadNloDigilockPhotodiode1(client, name + ':fhg-pdh-dc')
        self._fhg_pdh_rf = NloLaserHeadNloPdhPhotodiode1(client, name + ':fhg-pdh-rf')
        self._pump = NloLaserHeadNloPhotodiode1(client, name + ':pump')
        self._pump_dep = NloLaserHeadNloPhotodiode1(client, name + ':pump-dep')
        self._sig = NloLaserHeadNloPhotodiode1(client, name + ':sig')

    @property
    def dl(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._dl

    @property
    def amp(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._amp

    @property
    def fiber(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._fiber

    @property
    def shg(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._shg

    @property
    def shg_input(self) -> 'PdCal':
        return self._shg_input

    @property
    def shg_int(self) -> 'NloLaserHeadNloDigilockPhotodiode1':
        return self._shg_int

    @property
    def shg_pdh_dc(self) -> 'NloLaserHeadNloDigilockPhotodiode1':
        return self._shg_pdh_dc

    @property
    def shg_pdh_rf(self) -> 'NloLaserHeadNloPdhPhotodiode1':
        return self._shg_pdh_rf

    @property
    def fhg(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._fhg

    @property
    def fhg_int(self) -> 'NloLaserHeadNloDigilockPhotodiode1':
        return self._fhg_int

    @property
    def fhg_pdh_dc(self) -> 'NloLaserHeadNloDigilockPhotodiode1':
        return self._fhg_pdh_dc

    @property
    def fhg_pdh_rf(self) -> 'NloLaserHeadNloPdhPhotodiode1':
        return self._fhg_pdh_rf

    @property
    def pump(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._pump

    @property
    def pump_dep(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._pump_dep

    @property
    def sig(self) -> 'NloLaserHeadNloPhotodiode1':
        return self._sig


class NloLaserHeadNloPhotodiode1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power = DecopReal(client, name + ':power')
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class NloLaserHeadNloDigilockPhotodiode1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset


class NloLaserHeadNloPdhPhotodiode1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._gain = MutableDecopReal(client, name + ':gain')

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def gain(self) -> 'MutableDecopReal':
        return self._gain


class NloPowerOptimization:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ongoing = DecopBoolean(client, name + ':ongoing')
        self._progress = DecopInteger(client, name + ':progress')
        self._status = DecopInteger(client, name + ':status')
        self._status_string = DecopString(client, name + ':status-string')
        self._last_time_optimized = DecopString(client, name + ':last-time-optimized')
        self._shg_advanced = MutableDecopBoolean(client, name + ':shg-advanced')
        self._stage1 = NloStage1(client, name + ':stage1')
        self._stage2 = NloStage1(client, name + ':stage2')
        self._stage3 = NloStage1(client, name + ':stage3')
        self._stage4 = NloStage1(client, name + ':stage4')
        self._stage5 = NloStage1(client, name + ':stage5')
        self._progress_data_amp = DecopBinary(client, name + ':progress-data-amp')
        self._progress_data_shg = DecopBinary(client, name + ':progress-data-shg')
        self._progress_data_fiber = DecopBinary(client, name + ':progress-data-fiber')
        self._progress_data_fhg = DecopBinary(client, name + ':progress-data-fhg')
        self._abort = MutableDecopBoolean(client, name + ':abort')

    @property
    def ongoing(self) -> 'DecopBoolean':
        return self._ongoing

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_string(self) -> 'DecopString':
        return self._status_string

    @property
    def last_time_optimized(self) -> 'DecopString':
        return self._last_time_optimized

    @property
    def shg_advanced(self) -> 'MutableDecopBoolean':
        return self._shg_advanced

    @property
    def stage1(self) -> 'NloStage1':
        return self._stage1

    @property
    def stage2(self) -> 'NloStage1':
        return self._stage2

    @property
    def stage3(self) -> 'NloStage1':
        return self._stage3

    @property
    def stage4(self) -> 'NloStage1':
        return self._stage4

    @property
    def stage5(self) -> 'NloStage1':
        return self._stage5

    @property
    def progress_data_amp(self) -> 'DecopBinary':
        return self._progress_data_amp

    @property
    def progress_data_shg(self) -> 'DecopBinary':
        return self._progress_data_shg

    @property
    def progress_data_fiber(self) -> 'DecopBinary':
        return self._progress_data_fiber

    @property
    def progress_data_fhg(self) -> 'DecopBinary':
        return self._progress_data_fhg

    @property
    def abort(self) -> 'MutableDecopBoolean':
        return self._abort

    def start_optimization_all(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-all', input_stream=None, output_type=None, return_type=int)

    def start_optimization_amp(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-amp', input_stream=None, output_type=None, return_type=int)

    def start_optimization_shg(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-shg', input_stream=None, output_type=None, return_type=int)

    def start_optimization_fiber(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-fiber', input_stream=None, output_type=None, return_type=int)

    def start_optimization_fhg(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization-fhg', input_stream=None, output_type=None, return_type=int)


class NloStage1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input = NloOptInput1(client, name + ':input')
        self._progress = DecopInteger(client, name + ':progress')
        self._optimization_allowed = DecopBoolean(client, name + ':optimization-allowed')
        self._optimization_in_progress = DecopBoolean(client, name + ':optimization-in-progress')
        self._restore_on_abort = MutableDecopBoolean(client, name + ':restore-on-abort')
        self._restore_on_regress = MutableDecopBoolean(client, name + ':restore-on-regress')
        self._regress_tolerance = MutableDecopInteger(client, name + ':regress-tolerance')
        self._autosave_actuator_values = MutableDecopBoolean(client, name + ':autosave-actuator-values')

    @property
    def input(self) -> 'NloOptInput1':
        return self._input

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def optimization_allowed(self) -> 'DecopBoolean':
        return self._optimization_allowed

    @property
    def optimization_in_progress(self) -> 'DecopBoolean':
        return self._optimization_in_progress

    @property
    def restore_on_abort(self) -> 'MutableDecopBoolean':
        return self._restore_on_abort

    @property
    def restore_on_regress(self) -> 'MutableDecopBoolean':
        return self._restore_on_regress

    @property
    def regress_tolerance(self) -> 'MutableDecopInteger':
        return self._regress_tolerance

    @property
    def autosave_actuator_values(self) -> 'MutableDecopBoolean':
        return self._autosave_actuator_values

    def start_optimization(self) -> int:
        return self.__client.exec(self.__name + ':start-optimization', input_stream=None, output_type=None, return_type=int)


class NloOptInput1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_calibrated = DecopReal(client, name + ':value-calibrated')

    @property
    def value_calibrated(self) -> 'DecopReal':
        return self._value_calibrated


class AutoNlo:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._automatic_mode = MutableDecopBoolean(client, name + ':automatic-mode')
        self._laser_on = MutableDecopBoolean(client, name + ':laser-on')
        self._emission = DecopBoolean(client, name + ':emission')
        self._operation_time_master = DecopReal(client, name + ':operation-time-master')
        self._operation_time_amplifier = DecopReal(client, name + ':operation-time-amplifier')
        self._operation_time_cavity = DecopReal(client, name + ':operation-time-cavity')
        self._operation_time_cavity_fhg = DecopReal(client, name + ':operation-time-cavity-fhg')
        self._amplifier_current_margin = DecopReal(client, name + ':amplifier-current-margin')
        self._conversion_efficiency = DecopReal(client, name + ':conversion-efficiency')
        self._conversion_efficiency_fhg = DecopReal(client, name + ':conversion-efficiency-fhg')
        self._wavelength = DecopReal(client, name + ':wavelength')
        self._wavemeter = AutoNloWavemeter(client, name + ':wavemeter')

    @property
    def automatic_mode(self) -> 'MutableDecopBoolean':
        return self._automatic_mode

    @property
    def laser_on(self) -> 'MutableDecopBoolean':
        return self._laser_on

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def operation_time_master(self) -> 'DecopReal':
        return self._operation_time_master

    @property
    def operation_time_amplifier(self) -> 'DecopReal':
        return self._operation_time_amplifier

    @property
    def operation_time_cavity(self) -> 'DecopReal':
        return self._operation_time_cavity

    @property
    def operation_time_cavity_fhg(self) -> 'DecopReal':
        return self._operation_time_cavity_fhg

    @property
    def amplifier_current_margin(self) -> 'DecopReal':
        return self._amplifier_current_margin

    @property
    def conversion_efficiency(self) -> 'DecopReal':
        return self._conversion_efficiency

    @property
    def conversion_efficiency_fhg(self) -> 'DecopReal':
        return self._conversion_efficiency_fhg

    @property
    def wavelength(self) -> 'DecopReal':
        return self._wavelength

    @property
    def wavemeter(self) -> 'AutoNloWavemeter':
        return self._wavemeter

    def perform_single_mode_optimization(self) -> None:
        self.__client.exec(self.__name + ':perform-single-mode-optimization', input_stream=None, output_type=None, return_type=None)

    def perform_auto_align(self) -> None:
        self.__client.exec(self.__name + ':perform-auto-align', input_stream=None, output_type=None, return_type=None)

    def reset_operation_time_cavity(self) -> None:
        self.__client.exec(self.__name + ':reset-operation-time-cavity', input_stream=None, output_type=None, return_type=None)

    def reset_operation_time_cavity_fhg(self) -> None:
        self.__client.exec(self.__name + ':reset-operation-time-cavity-fhg', input_stream=None, output_type=None, return_type=None)


class AutoNloWavemeter:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._serial_number = MutableDecopString(client, name + ':serial-number')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._wavelength_before_optimization = DecopReal(client, name + ':wavelength-before-optimization')
        self._wavelength_after_optimization = DecopReal(client, name + ':wavelength-after-optimization')
        self._wavelength_temp_coeff = DecopReal(client, name + ':wavelength-temp-coeff')
        self._exposure_time = DecopInteger(client, name + ':exposure-time')

    @property
    def serial_number(self) -> 'MutableDecopString':
        return self._serial_number

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def wavelength_before_optimization(self) -> 'DecopReal':
        return self._wavelength_before_optimization

    @property
    def wavelength_after_optimization(self) -> 'DecopReal':
        return self._wavelength_after_optimization

    @property
    def wavelength_temp_coeff(self) -> 'DecopReal':
        return self._wavelength_temp_coeff

    @property
    def exposure_time(self) -> 'DecopInteger':
        return self._exposure_time


class Shg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel1(client, name + ':tc')
        self._cavity_tc = TcChannel1(client, name + ':cavity-tc')
        self._pc = PiezoDrv1(client, name + ':pc')
        self._scan = NloLaserHeadSiggen1(client, name + ':scan')
        self._scope = NloLaserHeadScopeT1(client, name + ':scope')
        self._lock = NloLaserHeadLockShg1(client, name + ':lock')
        self._factory_settings = ShgFactorySettings(client, name + ':factory-settings')

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc

    @property
    def cavity_tc(self) -> 'TcChannel1':
        return self._cavity_tc

    @property
    def pc(self) -> 'PiezoDrv1':
        return self._pc

    @property
    def scan(self) -> 'NloLaserHeadSiggen1':
        return self._scan

    @property
    def scope(self) -> 'NloLaserHeadScopeT1':
        return self._scope

    @property
    def lock(self) -> 'NloLaserHeadLockShg1':
        return self._lock

    @property
    def factory_settings(self) -> 'ShgFactorySettings':
        return self._factory_settings

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadSiggen1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._offset = MutableDecopReal(client, name + ':offset')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def offset(self) -> 'MutableDecopReal':
        return self._offset


class NloLaserHeadScopeT1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._variant = MutableDecopInteger(client, name + ':variant')
        self._update_rate = MutableDecopInteger(client, name + ':update-rate')
        self._channel1 = NloLaserHeadScopeChannelT1(client, name + ':channel1')
        self._channel2 = NloLaserHeadScopeChannelT1(client, name + ':channel2')
        self._channelx = NloLaserHeadScopeXAxisT1(client, name + ':channelx')
        self._timescale = MutableDecopReal(client, name + ':timescale')
        self._data = DecopBinary(client, name + ':data')

    @property
    def variant(self) -> 'MutableDecopInteger':
        return self._variant

    @property
    def update_rate(self) -> 'MutableDecopInteger':
        return self._update_rate

    @property
    def channel1(self) -> 'NloLaserHeadScopeChannelT1':
        return self._channel1

    @property
    def channel2(self) -> 'NloLaserHeadScopeChannelT1':
        return self._channel2

    @property
    def channelx(self) -> 'NloLaserHeadScopeXAxisT1':
        return self._channelx

    @property
    def timescale(self) -> 'MutableDecopReal':
        return self._timescale

    @property
    def data(self) -> 'DecopBinary':
        return self._data


class NloLaserHeadScopeChannelT1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class NloLaserHeadScopeXAxisT1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._xy_signal = MutableDecopInteger(client, name + ':xy-signal')
        self._scope_timescale = MutableDecopReal(client, name + ':scope-timescale')
        self._spectrum_range = MutableDecopReal(client, name + ':spectrum-range')
        self._spectrum_omit_dc = MutableDecopBoolean(client, name + ':spectrum-omit-dc')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def xy_signal(self) -> 'MutableDecopInteger':
        return self._xy_signal

    @property
    def scope_timescale(self) -> 'MutableDecopReal':
        return self._scope_timescale

    @property
    def spectrum_range(self) -> 'MutableDecopReal':
        return self._spectrum_range

    @property
    def spectrum_omit_dc(self) -> 'MutableDecopBoolean':
        return self._spectrum_omit_dc

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class NloLaserHeadLockShg1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._lock_enabled = MutableDecopBoolean(client, name + ':lock-enabled')
        self._pid_selection = MutableDecopInteger(client, name + ':pid-selection')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._relock = NloLaserHeadRelock1(client, name + ':relock')
        self._window = NloLaserHeadWindow1(client, name + ':window')
        self._pid1 = NloLaserHeadPid1(client, name + ':pid1')
        self._pid2 = NloLaserHeadPid1(client, name + ':pid2')
        self._analog_dl_gain = NloLaserHeadMinifalc1(client, name + ':analog-dl-gain')
        self._local_oscillator = NloLaserHeadLocalOscillatorShg1(client, name + ':local-oscillator')
        self._cavity_fast_pzt_voltage = MutableDecopReal(client, name + ':cavity-fast-pzt-voltage')
        self._cavity_slow_pzt_voltage = MutableDecopReal(client, name + ':cavity-slow-pzt-voltage')
        self._background_trace = DecopBinary(client, name + ':background-trace')
        self._candidates = DecopBinary(client, name + ':candidates')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def lock_enabled(self) -> 'MutableDecopBoolean':
        return self._lock_enabled

    @property
    def pid_selection(self) -> 'MutableDecopInteger':
        return self._pid_selection

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def relock(self) -> 'NloLaserHeadRelock1':
        return self._relock

    @property
    def window(self) -> 'NloLaserHeadWindow1':
        return self._window

    @property
    def pid1(self) -> 'NloLaserHeadPid1':
        return self._pid1

    @property
    def pid2(self) -> 'NloLaserHeadPid1':
        return self._pid2

    @property
    def analog_dl_gain(self) -> 'NloLaserHeadMinifalc1':
        return self._analog_dl_gain

    @property
    def local_oscillator(self) -> 'NloLaserHeadLocalOscillatorShg1':
        return self._local_oscillator

    @property
    def cavity_fast_pzt_voltage(self) -> 'MutableDecopReal':
        return self._cavity_fast_pzt_voltage

    @property
    def cavity_slow_pzt_voltage(self) -> 'MutableDecopReal':
        return self._cavity_slow_pzt_voltage

    @property
    def background_trace(self) -> 'DecopBinary':
        return self._background_trace

    @property
    def candidates(self) -> 'DecopBinary':
        return self._candidates


class NloLaserHeadRelock1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._delay = MutableDecopReal(client, name + ':delay')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def delay(self) -> 'MutableDecopReal':
        return self._delay


class NloLaserHeadWindow1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._threshold = MutableDecopReal(client, name + ':threshold')
        self._level_hysteresis = MutableDecopReal(client, name + ':level-hysteresis')
        self._calibration = NloLaserHeadWindowCalibration2(client, name + ':calibration')

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def threshold(self) -> 'MutableDecopReal':
        return self._threshold

    @property
    def level_hysteresis(self) -> 'MutableDecopReal':
        return self._level_hysteresis

    @property
    def calibration(self) -> 'NloLaserHeadWindowCalibration2':
        return self._calibration


class NloLaserHeadWindowCalibration2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power_min = MutableDecopReal(client, name + ':power-min')
        self._power_max = MutableDecopReal(client, name + ':power-max')
        self._threshold_min = MutableDecopReal(client, name + ':threshold-min')
        self._threshold_max = MutableDecopReal(client, name + ':threshold-max')

    @property
    def power_min(self) -> 'MutableDecopReal':
        return self._power_min

    @property
    def power_max(self) -> 'MutableDecopReal':
        return self._power_max

    @property
    def threshold_min(self) -> 'MutableDecopReal':
        return self._threshold_min

    @property
    def threshold_max(self) -> 'MutableDecopReal':
        return self._threshold_max


class NloLaserHeadPid1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._gain = NloLaserHeadGain1(client, name + ':gain')

    @property
    def gain(self) -> 'NloLaserHeadGain1':
        return self._gain


class NloLaserHeadGain1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._p = MutableDecopReal(client, name + ':p')
        self._i = MutableDecopReal(client, name + ':i')
        self._d = MutableDecopReal(client, name + ':d')
        self._i_cutoff = MutableDecopReal(client, name + ':i-cutoff')
        self._i_cutoff_enabled = MutableDecopBoolean(client, name + ':i-cutoff-enabled')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def p(self) -> 'MutableDecopReal':
        return self._p

    @property
    def i(self) -> 'MutableDecopReal':
        return self._i

    @property
    def d(self) -> 'MutableDecopReal':
        return self._d

    @property
    def i_cutoff(self) -> 'MutableDecopReal':
        return self._i_cutoff

    @property
    def i_cutoff_enabled(self) -> 'MutableDecopBoolean':
        return self._i_cutoff_enabled


class NloLaserHeadMinifalc1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._p_gain = MutableDecopReal(client, name + ':p-gain')

    @property
    def p_gain(self) -> 'MutableDecopReal':
        return self._p_gain


class NloLaserHeadLocalOscillatorShg1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._coupled_modulation = MutableDecopBoolean(client, name + ':coupled-modulation')
        self._use_fast_oscillator = MutableDecopBoolean(client, name + ':use-fast-oscillator')
        self._use_external_oscillator = MutableDecopBoolean(client, name + ':use-external-oscillator')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._attenuation_raw = MutableDecopInteger(client, name + ':attenuation-raw')
        self._phase_shift = MutableDecopReal(client, name + ':phase-shift')
        self._auto_pdh_state = DecopInteger(client, name + ':auto-pdh-state')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def coupled_modulation(self) -> 'MutableDecopBoolean':
        return self._coupled_modulation

    @property
    def use_fast_oscillator(self) -> 'MutableDecopBoolean':
        return self._use_fast_oscillator

    @property
    def use_external_oscillator(self) -> 'MutableDecopBoolean':
        return self._use_external_oscillator

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def attenuation_raw(self) -> 'MutableDecopInteger':
        return self._attenuation_raw

    @property
    def phase_shift(self) -> 'MutableDecopReal':
        return self._phase_shift

    @property
    def auto_pdh_state(self) -> 'DecopInteger':
        return self._auto_pdh_state

    def auto_pdh(self) -> None:
        self.__client.exec(self.__name + ':auto-pdh', input_stream=None, output_type=None, return_type=None)

    def auto_pdh_abort(self) -> None:
        self.__client.exec(self.__name + ':auto-pdh-abort', input_stream=None, output_type=None, return_type=None)


class ShgFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._modified = DecopBoolean(client, name + ':modified')
        self._tc = NloLaserHeadTcFactorySettings(client, name + ':tc')
        self._cavity_tc = NloLaserHeadTcFactorySettings(client, name + ':cavity-tc')
        self._pc = NloLaserHeadPcFactorySettings(client, name + ':pc')
        self._pd = NloLaserHeadShgPhotodiodesFactorySettings(client, name + ':pd')
        self._lock = NloLaserHeadLockFactorySettings(client, name + ':lock')
        self._auto_nlo = NloLaserHeadAutoNloFactorySettings(client, name + ':auto-nlo')

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    @property
    def tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._tc

    @property
    def cavity_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._cavity_tc

    @property
    def pc(self) -> 'NloLaserHeadPcFactorySettings':
        return self._pc

    @property
    def pd(self) -> 'NloLaserHeadShgPhotodiodesFactorySettings':
        return self._pd

    @property
    def lock(self) -> 'NloLaserHeadLockFactorySettings':
        return self._lock

    @property
    def auto_nlo(self) -> 'NloLaserHeadAutoNloFactorySettings':
        return self._auto_nlo

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadTcFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_min = MutableDecopReal(client, name + ':temp-min')
        self._temp_max = MutableDecopReal(client, name + ':temp-max')
        self._temp_set = MutableDecopReal(client, name + ':temp-set')
        self._temp_roc_enabled = MutableDecopBoolean(client, name + ':temp-roc-enabled')
        self._temp_roc_limit = MutableDecopReal(client, name + ':temp-roc-limit')
        self._current_max = MutableDecopReal(client, name + ':current-max')
        self._current_min = MutableDecopReal(client, name + ':current-min')
        self._p_gain = MutableDecopReal(client, name + ':p-gain')
        self._i_gain = MutableDecopReal(client, name + ':i-gain')
        self._d_gain = MutableDecopReal(client, name + ':d-gain')
        self._c_gain = MutableDecopReal(client, name + ':c-gain')
        self._ok_tolerance = MutableDecopReal(client, name + ':ok-tolerance')
        self._ok_time = MutableDecopReal(client, name + ':ok-time')
        self._timeout = MutableDecopInteger(client, name + ':timeout')
        self._power_source = MutableDecopInteger(client, name + ':power-source')
        self._ntc_series_resistance = MutableDecopReal(client, name + ':ntc-series-resistance')

    @property
    def temp_min(self) -> 'MutableDecopReal':
        return self._temp_min

    @property
    def temp_max(self) -> 'MutableDecopReal':
        return self._temp_max

    @property
    def temp_set(self) -> 'MutableDecopReal':
        return self._temp_set

    @property
    def temp_roc_enabled(self) -> 'MutableDecopBoolean':
        return self._temp_roc_enabled

    @property
    def temp_roc_limit(self) -> 'MutableDecopReal':
        return self._temp_roc_limit

    @property
    def current_max(self) -> 'MutableDecopReal':
        return self._current_max

    @property
    def current_min(self) -> 'MutableDecopReal':
        return self._current_min

    @property
    def p_gain(self) -> 'MutableDecopReal':
        return self._p_gain

    @property
    def i_gain(self) -> 'MutableDecopReal':
        return self._i_gain

    @property
    def d_gain(self) -> 'MutableDecopReal':
        return self._d_gain

    @property
    def c_gain(self) -> 'MutableDecopReal':
        return self._c_gain

    @property
    def ok_tolerance(self) -> 'MutableDecopReal':
        return self._ok_tolerance

    @property
    def ok_time(self) -> 'MutableDecopReal':
        return self._ok_time

    @property
    def timeout(self) -> 'MutableDecopInteger':
        return self._timeout

    @property
    def power_source(self) -> 'MutableDecopInteger':
        return self._power_source

    @property
    def ntc_series_resistance(self) -> 'MutableDecopReal':
        return self._ntc_series_resistance


class NloLaserHeadPcFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._capacitance = MutableDecopReal(client, name + ':capacitance')
        self._scan_offset = MutableDecopReal(client, name + ':scan-offset')
        self._scan_amplitude = MutableDecopReal(client, name + ':scan-amplitude')
        self._scan_frequency = MutableDecopReal(client, name + ':scan-frequency')

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def capacitance(self) -> 'MutableDecopReal':
        return self._capacitance

    @property
    def scan_offset(self) -> 'MutableDecopReal':
        return self._scan_offset

    @property
    def scan_amplitude(self) -> 'MutableDecopReal':
        return self._scan_amplitude

    @property
    def scan_frequency(self) -> 'MutableDecopReal':
        return self._scan_frequency


class NloLaserHeadShgPhotodiodesFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._shg = NloLaserHeadPdFactorySettings1(client, name + ':shg')
        self._shg_input = NloLaserHeadPdFactorySettings2(client, name + ':shg-input')
        self._fiber = NloLaserHeadPdFactorySettings1(client, name + ':fiber')
        self._int = NloLaserHeadPdDigilockFactorySettings(client, name + ':int')
        self._pdh_dc = NloLaserHeadPdDigilockFactorySettings(client, name + ':pdh-dc')
        self._pdh_rf = NloLaserHeadPdPdhFactorySettings(client, name + ':pdh-rf')

    @property
    def shg(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._shg

    @property
    def shg_input(self) -> 'NloLaserHeadPdFactorySettings2':
        return self._shg_input

    @property
    def fiber(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._fiber

    @property
    def int(self) -> 'NloLaserHeadPdDigilockFactorySettings':
        return self._int

    @property
    def pdh_dc(self) -> 'NloLaserHeadPdDigilockFactorySettings':
        return self._pdh_dc

    @property
    def pdh_rf(self) -> 'NloLaserHeadPdPdhFactorySettings':
        return self._pdh_rf


class NloLaserHeadPdFactorySettings1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class NloLaserHeadPdFactorySettings2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class NloLaserHeadPdDigilockFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset


class NloLaserHeadPdPdhFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._gain = MutableDecopReal(client, name + ':gain')

    @property
    def gain(self) -> 'MutableDecopReal':
        return self._gain


class NloLaserHeadLockFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._pid_selection = MutableDecopInteger(client, name + ':pid-selection')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._relock = NloLaserHeadRelockFactorySettings(client, name + ':relock')
        self._window = NloLaserHeadLockWindowFactorySettings(client, name + ':window')
        self._pid1_gain = NloLaserHeadPidGainFactorySettings(client, name + ':pid1-gain')
        self._pid2_gain = NloLaserHeadPidGainFactorySettings(client, name + ':pid2-gain')
        self._analog_p_gain = MutableDecopReal(client, name + ':analog-p-gain')
        self._local_oscillator = NloLaserHeadLocalOscillatorFactorySettings(client, name + ':local-oscillator')

    @property
    def pid_selection(self) -> 'MutableDecopInteger':
        return self._pid_selection

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def relock(self) -> 'NloLaserHeadRelockFactorySettings':
        return self._relock

    @property
    def window(self) -> 'NloLaserHeadLockWindowFactorySettings':
        return self._window

    @property
    def pid1_gain(self) -> 'NloLaserHeadPidGainFactorySettings':
        return self._pid1_gain

    @property
    def pid2_gain(self) -> 'NloLaserHeadPidGainFactorySettings':
        return self._pid2_gain

    @property
    def analog_p_gain(self) -> 'MutableDecopReal':
        return self._analog_p_gain

    @property
    def local_oscillator(self) -> 'NloLaserHeadLocalOscillatorFactorySettings':
        return self._local_oscillator


class NloLaserHeadRelockFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._frequency = MutableDecopReal(client, name + ':frequency')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._delay = MutableDecopReal(client, name + ':delay')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def delay(self) -> 'MutableDecopReal':
        return self._delay


class NloLaserHeadLockWindowFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._threshold = MutableDecopReal(client, name + ':threshold')
        self._level_hysteresis = MutableDecopReal(client, name + ':level-hysteresis')

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def threshold(self) -> 'MutableDecopReal':
        return self._threshold

    @property
    def level_hysteresis(self) -> 'MutableDecopReal':
        return self._level_hysteresis


class NloLaserHeadPidGainFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._p = MutableDecopReal(client, name + ':p')
        self._i = MutableDecopReal(client, name + ':i')
        self._d = MutableDecopReal(client, name + ':d')
        self._i_cutoff = MutableDecopReal(client, name + ':i-cutoff')
        self._i_cutoff_enabled = MutableDecopBoolean(client, name + ':i-cutoff-enabled')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def p(self) -> 'MutableDecopReal':
        return self._p

    @property
    def i(self) -> 'MutableDecopReal':
        return self._i

    @property
    def d(self) -> 'MutableDecopReal':
        return self._d

    @property
    def i_cutoff(self) -> 'MutableDecopReal':
        return self._i_cutoff

    @property
    def i_cutoff_enabled(self) -> 'MutableDecopBoolean':
        return self._i_cutoff_enabled


class NloLaserHeadLocalOscillatorFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._use_fast_oscillator = MutableDecopBoolean(client, name + ':use-fast-oscillator')
        self._coupled_modulation = MutableDecopBoolean(client, name + ':coupled-modulation')
        self._attenuation_shg_raw = MutableDecopInteger(client, name + ':attenuation-shg-raw')
        self._attenuation_fhg_raw = MutableDecopInteger(client, name + ':attenuation-fhg-raw')
        self._phase_shift_shg = MutableDecopReal(client, name + ':phase-shift-shg')
        self._phase_shift_fhg = MutableDecopReal(client, name + ':phase-shift-fhg')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def use_fast_oscillator(self) -> 'MutableDecopBoolean':
        return self._use_fast_oscillator

    @property
    def coupled_modulation(self) -> 'MutableDecopBoolean':
        return self._coupled_modulation

    @property
    def attenuation_shg_raw(self) -> 'MutableDecopInteger':
        return self._attenuation_shg_raw

    @property
    def attenuation_fhg_raw(self) -> 'MutableDecopInteger':
        return self._attenuation_fhg_raw

    @property
    def phase_shift_shg(self) -> 'MutableDecopReal':
        return self._phase_shift_shg

    @property
    def phase_shift_fhg(self) -> 'MutableDecopReal':
        return self._phase_shift_fhg


class NloLaserHeadAutoNloFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._optimization_settings = NloLaserHeadAutoNloOptFactorySettings(client, name + ':optimization-settings')

    @property
    def optimization_settings(self) -> 'NloLaserHeadAutoNloOptFactorySettings':
        return self._optimization_settings


class NloLaserHeadAutoNloOptFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._pressure_compensation_enabled = MutableDecopBoolean(client, name + ':pressure-compensation-enabled')
        self._auto_align_amplifier_enabled = MutableDecopBoolean(client, name + ':auto-align-amplifier-enabled')
        self._auto_align_cavity_enabled = MutableDecopBoolean(client, name + ':auto-align-cavity-enabled')
        self._auto_align_advanced_enabled = MutableDecopBoolean(client, name + ':auto-align-advanced-enabled')

    @property
    def pressure_compensation_enabled(self) -> 'MutableDecopBoolean':
        return self._pressure_compensation_enabled

    @property
    def auto_align_amplifier_enabled(self) -> 'MutableDecopBoolean':
        return self._auto_align_amplifier_enabled

    @property
    def auto_align_cavity_enabled(self) -> 'MutableDecopBoolean':
        return self._auto_align_cavity_enabled

    @property
    def auto_align_advanced_enabled(self) -> 'MutableDecopBoolean':
        return self._auto_align_advanced_enabled


class Fhg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel1(client, name + ':tc')
        self._cavity_tc = TcChannel1(client, name + ':cavity-tc')
        self._pc = PiezoDrv1(client, name + ':pc')
        self._scan = NloLaserHeadSiggen1(client, name + ':scan')
        self._scope = NloLaserHeadScopeT1(client, name + ':scope')
        self._lock = NloLaserHeadLockFhg(client, name + ':lock')
        self._factory_settings = FhgFactorySettings(client, name + ':factory-settings')

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc

    @property
    def cavity_tc(self) -> 'TcChannel1':
        return self._cavity_tc

    @property
    def pc(self) -> 'PiezoDrv1':
        return self._pc

    @property
    def scan(self) -> 'NloLaserHeadSiggen1':
        return self._scan

    @property
    def scope(self) -> 'NloLaserHeadScopeT1':
        return self._scope

    @property
    def lock(self) -> 'NloLaserHeadLockFhg':
        return self._lock

    @property
    def factory_settings(self) -> 'FhgFactorySettings':
        return self._factory_settings

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadLockFhg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._lock_enabled = MutableDecopBoolean(client, name + ':lock-enabled')
        self._pid_selection = MutableDecopInteger(client, name + ':pid-selection')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._relock = NloLaserHeadRelock1(client, name + ':relock')
        self._window = NloLaserHeadWindow1(client, name + ':window')
        self._pid1 = NloLaserHeadPid1(client, name + ':pid1')
        self._pid2 = NloLaserHeadPid1(client, name + ':pid2')
        self._local_oscillator = NloLaserHeadLocalOscillatorFhg(client, name + ':local-oscillator')
        self._cavity_fast_pzt_voltage = MutableDecopReal(client, name + ':cavity-fast-pzt-voltage')
        self._cavity_slow_pzt_voltage = MutableDecopReal(client, name + ':cavity-slow-pzt-voltage')
        self._background_trace = DecopBinary(client, name + ':background-trace')
        self._candidates = DecopBinary(client, name + ':candidates')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def lock_enabled(self) -> 'MutableDecopBoolean':
        return self._lock_enabled

    @property
    def pid_selection(self) -> 'MutableDecopInteger':
        return self._pid_selection

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def relock(self) -> 'NloLaserHeadRelock1':
        return self._relock

    @property
    def window(self) -> 'NloLaserHeadWindow1':
        return self._window

    @property
    def pid1(self) -> 'NloLaserHeadPid1':
        return self._pid1

    @property
    def pid2(self) -> 'NloLaserHeadPid1':
        return self._pid2

    @property
    def local_oscillator(self) -> 'NloLaserHeadLocalOscillatorFhg':
        return self._local_oscillator

    @property
    def cavity_fast_pzt_voltage(self) -> 'MutableDecopReal':
        return self._cavity_fast_pzt_voltage

    @property
    def cavity_slow_pzt_voltage(self) -> 'MutableDecopReal':
        return self._cavity_slow_pzt_voltage

    @property
    def background_trace(self) -> 'DecopBinary':
        return self._background_trace

    @property
    def candidates(self) -> 'DecopBinary':
        return self._candidates


class NloLaserHeadLocalOscillatorFhg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._coupled_modulation = MutableDecopBoolean(client, name + ':coupled-modulation')
        self._use_fast_oscillator = MutableDecopBoolean(client, name + ':use-fast-oscillator')
        self._amplitude = MutableDecopReal(client, name + ':amplitude')
        self._attenuation_raw = MutableDecopInteger(client, name + ':attenuation-raw')
        self._phase_shift = MutableDecopReal(client, name + ':phase-shift')
        self._auto_pdh_state = DecopInteger(client, name + ':auto-pdh-state')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def coupled_modulation(self) -> 'MutableDecopBoolean':
        return self._coupled_modulation

    @property
    def use_fast_oscillator(self) -> 'MutableDecopBoolean':
        return self._use_fast_oscillator

    @property
    def amplitude(self) -> 'MutableDecopReal':
        return self._amplitude

    @property
    def attenuation_raw(self) -> 'MutableDecopInteger':
        return self._attenuation_raw

    @property
    def phase_shift(self) -> 'MutableDecopReal':
        return self._phase_shift

    @property
    def auto_pdh_state(self) -> 'DecopInteger':
        return self._auto_pdh_state

    def auto_pdh(self) -> None:
        self.__client.exec(self.__name + ':auto-pdh', input_stream=None, output_type=None, return_type=None)

    def auto_pdh_abort(self) -> None:
        self.__client.exec(self.__name + ':auto-pdh-abort', input_stream=None, output_type=None, return_type=None)


class FhgFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._modified = DecopBoolean(client, name + ':modified')
        self._tc = NloLaserHeadTcFactorySettings(client, name + ':tc')
        self._cavity_tc = NloLaserHeadTcFactorySettings(client, name + ':cavity-tc')
        self._pc = NloLaserHeadPcFactorySettings(client, name + ':pc')
        self._pd = NloLaserHeadFhgPhotodiodesFactorySettings(client, name + ':pd')
        self._lock = NloLaserHeadLockFactorySettings(client, name + ':lock')

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    @property
    def tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._tc

    @property
    def cavity_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._cavity_tc

    @property
    def pc(self) -> 'NloLaserHeadPcFactorySettings':
        return self._pc

    @property
    def pd(self) -> 'NloLaserHeadFhgPhotodiodesFactorySettings':
        return self._pd

    @property
    def lock(self) -> 'NloLaserHeadLockFactorySettings':
        return self._lock

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadFhgPhotodiodesFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._fhg = NloLaserHeadPdFactorySettings1(client, name + ':fhg')
        self._int = NloLaserHeadPdDigilockFactorySettings(client, name + ':int')
        self._pdh_dc = NloLaserHeadPdDigilockFactorySettings(client, name + ':pdh-dc')
        self._pdh_rf = NloLaserHeadPdPdhFactorySettings(client, name + ':pdh-rf')

    @property
    def fhg(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._fhg

    @property
    def int(self) -> 'NloLaserHeadPdDigilockFactorySettings':
        return self._int

    @property
    def pdh_dc(self) -> 'NloLaserHeadPdDigilockFactorySettings':
        return self._pdh_dc

    @property
    def pdh_rf(self) -> 'NloLaserHeadPdPdhFactorySettings':
        return self._pdh_rf


class Opo:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._crystal = OpoCrystal(client, name + ':crystal')
        self._cavity = OpoCavity(client, name + ':cavity')
        self._factory_settings = OpoFactorySettings(client, name + ':factory-settings')

    @property
    def crystal(self) -> 'OpoCrystal':
        return self._crystal

    @property
    def cavity(self) -> 'OpoCavity':
        return self._cavity

    @property
    def factory_settings(self) -> 'OpoFactorySettings':
        return self._factory_settings

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)


class OpoCrystal:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel1(client, name + ':tc')

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc


class OpoCavity:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel1(client, name + ':tc')
        self._pc = PiezoDrv1(client, name + ':pc')
        self._fast_pzt_voltage_set = MutableDecopReal(client, name + ':fast-pzt-voltage-set')
        self._slow_pzt_voltage_set = MutableDecopReal(client, name + ':slow-pzt-voltage-set')
        self._motor = NloLaserHeadMicronixMotor(client, name + ':motor')

    @property
    def tc(self) -> 'TcChannel1':
        return self._tc

    @property
    def pc(self) -> 'PiezoDrv1':
        return self._pc

    @property
    def fast_pzt_voltage_set(self) -> 'MutableDecopReal':
        return self._fast_pzt_voltage_set

    @property
    def slow_pzt_voltage_set(self) -> 'MutableDecopReal':
        return self._slow_pzt_voltage_set

    @property
    def motor(self) -> 'NloLaserHeadMicronixMotor':
        return self._motor


class NloLaserHeadMicronixMotor:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._position_set = MutableDecopReal(client, name + ':position-set')
        self._position_act = DecopReal(client, name + ':position-act')
        self._position_min = DecopReal(client, name + ':position-min')
        self._position_max = DecopReal(client, name + ':position-max')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def position_set(self) -> 'MutableDecopReal':
        return self._position_set

    @property
    def position_act(self) -> 'DecopReal':
        return self._position_act

    @property
    def position_min(self) -> 'DecopReal':
        return self._position_min

    @property
    def position_max(self) -> 'DecopReal':
        return self._position_max

    def recalibrate(self) -> None:
        self.__client.exec(self.__name + ':recalibrate', input_stream=None, output_type=None, return_type=None)


class OpoFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._modified = DecopBoolean(client, name + ':modified')
        self._crystal_tc = NloLaserHeadTcFactorySettings(client, name + ':crystal-tc')
        self._cavity_tc = NloLaserHeadTcFactorySettings(client, name + ':cavity-tc')
        self._cavity_pc = NloLaserHeadPcFactorySettings(client, name + ':cavity-pc')
        self._pd = NloLaserHeadOpoPhotodiodesFactorySettings(client, name + ':pd')

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    @property
    def crystal_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._crystal_tc

    @property
    def cavity_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._cavity_tc

    @property
    def cavity_pc(self) -> 'NloLaserHeadPcFactorySettings':
        return self._cavity_pc

    @property
    def pd(self) -> 'NloLaserHeadOpoPhotodiodesFactorySettings':
        return self._pd

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadOpoPhotodiodesFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._pump = NloLaserHeadPdFactorySettings1(client, name + ':pump')
        self._pump_dep = NloLaserHeadPdFactorySettings1(client, name + ':pump-dep')
        self._sig = NloLaserHeadPdFactorySettings1(client, name + ':sig')
        self._fiber = NloLaserHeadPdFactorySettings1(client, name + ':fiber')

    @property
    def pump(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._pump

    @property
    def pump_dep(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._pump_dep

    @property
    def sig(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._sig

    @property
    def fiber(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._fiber


class UvShg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._pump = Dpss2(client, name + ':pump')
        self._eom = UvEom(client, name + ':eom')
        self._cavity = UvCavity(client, name + ':cavity')
        self._crystal = UvCrystal(client, name + ':crystal')
        self._servo = NloLaserHeadUvServos(client, name + ':servo')
        self._pd = NloLaserHeadUvPhotoDiodes(client, name + ':pd')
        self._power_optimization = UvShgPowerOptimization(client, name + ':power-optimization')
        self._power_stabilization = UvShgPowerStabilization(client, name + ':power-stabilization')
        self._optimization_settings = UvShgOptimizationSettings(client, name + ':optimization-settings')
        self._scan = NloLaserHeadSiggen2(client, name + ':scan')
        self._scope = NloLaserHeadScopeT2(client, name + ':scope')
        self._lock = NloLaserHeadLockShg2(client, name + ':lock')
        self._factory_settings = UvFactorySettings(client, name + ':factory-settings')
        self._status_parameters = UvStatusParameters(client, name + ':status-parameters')
        self._power_margin = DecopReal(client, name + ':power-margin')
        self._hwp_transmittance = DecopReal(client, name + ':hwp-transmittance')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._specs_fulfilled = DecopBoolean(client, name + ':specs-fulfilled')
        self._error = DecopInteger(client, name + ':error')
        self._error_txt = DecopString(client, name + ':error-txt')
        self._operation_time = DecopReal(client, name + ':operation-time')
        self._remaining_optics_spots = DecopInteger(client, name + ':remaining-optics-spots')
        self._baseplate_temperature = DecopReal(client, name + ':baseplate-temperature')
        self._ssw_ver = DecopString(client, name + ':ssw-ver')

    @property
    def pump(self) -> 'Dpss2':
        return self._pump

    @property
    def eom(self) -> 'UvEom':
        return self._eom

    @property
    def cavity(self) -> 'UvCavity':
        return self._cavity

    @property
    def crystal(self) -> 'UvCrystal':
        return self._crystal

    @property
    def servo(self) -> 'NloLaserHeadUvServos':
        return self._servo

    @property
    def pd(self) -> 'NloLaserHeadUvPhotoDiodes':
        return self._pd

    @property
    def power_optimization(self) -> 'UvShgPowerOptimization':
        return self._power_optimization

    @property
    def power_stabilization(self) -> 'UvShgPowerStabilization':
        return self._power_stabilization

    @property
    def optimization_settings(self) -> 'UvShgOptimizationSettings':
        return self._optimization_settings

    @property
    def scan(self) -> 'NloLaserHeadSiggen2':
        return self._scan

    @property
    def scope(self) -> 'NloLaserHeadScopeT2':
        return self._scope

    @property
    def lock(self) -> 'NloLaserHeadLockShg2':
        return self._lock

    @property
    def factory_settings(self) -> 'UvFactorySettings':
        return self._factory_settings

    @property
    def status_parameters(self) -> 'UvStatusParameters':
        return self._status_parameters

    @property
    def power_margin(self) -> 'DecopReal':
        return self._power_margin

    @property
    def hwp_transmittance(self) -> 'DecopReal':
        return self._hwp_transmittance

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def specs_fulfilled(self) -> 'DecopBoolean':
        return self._specs_fulfilled

    @property
    def error(self) -> 'DecopInteger':
        return self._error

    @property
    def error_txt(self) -> 'DecopString':
        return self._error_txt

    @property
    def operation_time(self) -> 'DecopReal':
        return self._operation_time

    @property
    def remaining_optics_spots(self) -> 'DecopInteger':
        return self._remaining_optics_spots

    @property
    def baseplate_temperature(self) -> 'DecopReal':
        return self._baseplate_temperature

    @property
    def ssw_ver(self) -> 'DecopString':
        return self._ssw_ver

    def store(self) -> None:
        self.__client.exec(self.__name + ':store', input_stream=None, output_type=None, return_type=None)

    def restore(self) -> None:
        self.__client.exec(self.__name + ':restore', input_stream=None, output_type=None, return_type=None)

    def perform_optimization(self) -> None:
        self.__client.exec(self.__name + ':perform-optimization', input_stream=None, output_type=None, return_type=None)

    def perform_optics_shift(self) -> None:
        self.__client.exec(self.__name + ':perform-optics-shift', input_stream=None, output_type=None, return_type=None)

    def clear_errors(self) -> None:
        self.__client.exec(self.__name + ':clear-errors', input_stream=None, output_type=None, return_type=None)


class Dpss2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._tc_status = DecopInteger(client, name + ':tc-status')
        self._tc_status_txt = DecopString(client, name + ':tc-status-txt')
        self._error_code = DecopInteger(client, name + ':error-code')
        self._error_txt = DecopString(client, name + ':error-txt')
        self._operation_time = DecopReal(client, name + ':operation-time')
        self._power_set = DecopReal(client, name + ':power-set')
        self._power_act = DecopReal(client, name + ':power-act')
        self._power_max = DecopReal(client, name + ':power-max')
        self._power_margin = DecopReal(client, name + ':power-margin')
        self._current_act = DecopReal(client, name + ':current-act')
        self._current_max = DecopReal(client, name + ':current-max')
        self._temperature_control = DpssTemperatureParameters2(client, name + ':temperature-control')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def tc_status(self) -> 'DecopInteger':
        return self._tc_status

    @property
    def tc_status_txt(self) -> 'DecopString':
        return self._tc_status_txt

    @property
    def error_code(self) -> 'DecopInteger':
        return self._error_code

    @property
    def error_txt(self) -> 'DecopString':
        return self._error_txt

    @property
    def operation_time(self) -> 'DecopReal':
        return self._operation_time

    @property
    def power_set(self) -> 'DecopReal':
        return self._power_set

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act

    @property
    def power_max(self) -> 'DecopReal':
        return self._power_max

    @property
    def power_margin(self) -> 'DecopReal':
        return self._power_margin

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def current_max(self) -> 'DecopReal':
        return self._current_max

    @property
    def temperature_control(self) -> 'DpssTemperatureParameters2':
        return self._temperature_control


class DpssTemperatureParameters2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._t1 = DpssTemperatureControlParameters2(client, name + ':t1')
        self._t2 = DpssTemperatureControlParameters2(client, name + ':t2')
        self._t3 = DpssTemperatureControlParameters2(client, name + ':t3')
        self._t4 = DpssTemperatureControlParameters2(client, name + ':t4')
        self._t5 = DpssTemperatureControlParameters2(client, name + ':t5')

    @property
    def t1(self) -> 'DpssTemperatureControlParameters2':
        return self._t1

    @property
    def t2(self) -> 'DpssTemperatureControlParameters2':
        return self._t2

    @property
    def t3(self) -> 'DpssTemperatureControlParameters2':
        return self._t3

    @property
    def t4(self) -> 'DpssTemperatureControlParameters2':
        return self._t4

    @property
    def t5(self) -> 'DpssTemperatureControlParameters2':
        return self._t5


class DpssTemperatureControlParameters2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_act = DecopReal(client, name + ':temp-act')
        self._temp_set = DecopReal(client, name + ':temp-set')
        self._temp_set_min = DecopReal(client, name + ':temp-set-min')
        self._temp_set_max = DecopReal(client, name + ':temp-set-max')
        self._temp_roc_limit = DecopReal(client, name + ':temp-roc-limit')

    @property
    def temp_act(self) -> 'DecopReal':
        return self._temp_act

    @property
    def temp_set(self) -> 'DecopReal':
        return self._temp_set

    @property
    def temp_set_min(self) -> 'DecopReal':
        return self._temp_set_min

    @property
    def temp_set_max(self) -> 'DecopReal':
        return self._temp_set_max

    @property
    def temp_roc_limit(self) -> 'DecopReal':
        return self._temp_roc_limit


class UvEom:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel2(client, name + ':tc')

    @property
    def tc(self) -> 'TcChannel2':
        return self._tc


class TcChannel2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._temp_act = DecopReal(client, name + ':temp-act')
        self._temp_set = DecopReal(client, name + ':temp-set')
        self._external_input = ExtInput3(client, name + ':external-input')
        self._ready = DecopBoolean(client, name + ':ready')
        self._fault = DecopBoolean(client, name + ':fault')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._t_loop = TcChannelTLoop2(client, name + ':t-loop')
        self._c_loop = TcChannelCLoop1(client, name + ':c-loop')
        self._limits = TcChannelCheck2(client, name + ':limits')
        self._current_set = DecopReal(client, name + ':current-set')
        self._current_set_min = DecopReal(client, name + ':current-set-min')
        self._current_set_max = DecopReal(client, name + ':current-set-max')
        self._current_act = DecopReal(client, name + ':current-act')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._resistance = DecopReal(client, name + ':resistance')
        self._ntc_series_resistance = DecopReal(client, name + ':ntc-series-resistance')
        self._ntc_parallel_resistance = DecopReal(client, name + ':ntc-parallel-resistance')
        self._temp_set_min = DecopReal(client, name + ':temp-set-min')
        self._temp_set_max = DecopReal(client, name + ':temp-set-max')
        self._temp_reset = DecopBoolean(client, name + ':temp-reset')
        self._temp_roc_enabled = DecopBoolean(client, name + ':temp-roc-enabled')
        self._temp_roc_limit = DecopReal(client, name + ':temp-roc-limit')
        self._power_source = DecopInteger(client, name + ':power-source')
        self._drv_voltage = DecopReal(client, name + ':drv-voltage')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def temp_act(self) -> 'DecopReal':
        return self._temp_act

    @property
    def temp_set(self) -> 'DecopReal':
        return self._temp_set

    @property
    def external_input(self) -> 'ExtInput3':
        return self._external_input

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def fault(self) -> 'DecopBoolean':
        return self._fault

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def t_loop(self) -> 'TcChannelTLoop2':
        return self._t_loop

    @property
    def c_loop(self) -> 'TcChannelCLoop1':
        return self._c_loop

    @property
    def limits(self) -> 'TcChannelCheck2':
        return self._limits

    @property
    def current_set(self) -> 'DecopReal':
        return self._current_set

    @property
    def current_set_min(self) -> 'DecopReal':
        return self._current_set_min

    @property
    def current_set_max(self) -> 'DecopReal':
        return self._current_set_max

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def resistance(self) -> 'DecopReal':
        return self._resistance

    @property
    def ntc_series_resistance(self) -> 'DecopReal':
        return self._ntc_series_resistance

    @property
    def ntc_parallel_resistance(self) -> 'DecopReal':
        return self._ntc_parallel_resistance

    @property
    def temp_set_min(self) -> 'DecopReal':
        return self._temp_set_min

    @property
    def temp_set_max(self) -> 'DecopReal':
        return self._temp_set_max

    @property
    def temp_reset(self) -> 'DecopBoolean':
        return self._temp_reset

    @property
    def temp_roc_enabled(self) -> 'DecopBoolean':
        return self._temp_roc_enabled

    @property
    def temp_roc_limit(self) -> 'DecopReal':
        return self._temp_roc_limit

    @property
    def power_source(self) -> 'DecopInteger':
        return self._power_source

    @property
    def drv_voltage(self) -> 'DecopReal':
        return self._drv_voltage


class ExtInput3:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = DecopInteger(client, name + ':signal')
        self._factor = DecopReal(client, name + ':factor')
        self._enabled = DecopBoolean(client, name + ':enabled')

    @property
    def signal(self) -> 'DecopInteger':
        return self._signal

    @property
    def factor(self) -> 'DecopReal':
        return self._factor

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled


class TcChannelTLoop2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on = DecopBoolean(client, name + ':on')
        self._p_gain = DecopReal(client, name + ':p-gain')
        self._i_gain = DecopReal(client, name + ':i-gain')
        self._d_gain = DecopReal(client, name + ':d-gain')
        self._ok_tolerance = DecopReal(client, name + ':ok-tolerance')
        self._ok_time = DecopReal(client, name + ':ok-time')

    @property
    def on(self) -> 'DecopBoolean':
        return self._on

    @property
    def p_gain(self) -> 'DecopReal':
        return self._p_gain

    @property
    def i_gain(self) -> 'DecopReal':
        return self._i_gain

    @property
    def d_gain(self) -> 'DecopReal':
        return self._d_gain

    @property
    def ok_tolerance(self) -> 'DecopReal':
        return self._ok_tolerance

    @property
    def ok_time(self) -> 'DecopReal':
        return self._ok_time


class TcChannelCLoop1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on = DecopBoolean(client, name + ':on')
        self._i_gain = DecopReal(client, name + ':i-gain')

    @property
    def on(self) -> 'DecopBoolean':
        return self._on

    @property
    def i_gain(self) -> 'DecopReal':
        return self._i_gain


class TcChannelCheck2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._temp_min = DecopReal(client, name + ':temp-min')
        self._temp_max = DecopReal(client, name + ':temp-max')
        self._timeout = DecopInteger(client, name + ':timeout')
        self._timed_out = DecopBoolean(client, name + ':timed-out')
        self._out_of_range = DecopBoolean(client, name + ':out-of-range')

    @property
    def temp_min(self) -> 'DecopReal':
        return self._temp_min

    @property
    def temp_max(self) -> 'DecopReal':
        return self._temp_max

    @property
    def timeout(self) -> 'DecopInteger':
        return self._timeout

    @property
    def timed_out(self) -> 'DecopBoolean':
        return self._timed_out

    @property
    def out_of_range(self) -> 'DecopBoolean':
        return self._out_of_range


class UvCavity:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel2(client, name + ':tc')
        self._pc = PiezoDrv3(client, name + ':pc')

    @property
    def tc(self) -> 'TcChannel2':
        return self._tc

    @property
    def pc(self) -> 'PiezoDrv3':
        return self._pc


class PiezoDrv3:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._voltage_set = DecopReal(client, name + ':voltage-set')
        self._voltage_min = DecopReal(client, name + ':voltage-min')
        self._voltage_max = DecopReal(client, name + ':voltage-max')
        self._voltage_set_dithering = DecopBoolean(client, name + ':voltage-set-dithering')
        self._external_input = ExtInput3(client, name + ':external-input')
        self._output_filter = OutputFilter3(client, name + ':output-filter')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._feedforward_master = DecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = DecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = DecopReal(client, name + ':feedforward-factor')
        self._heatsink_temp = DecopReal(client, name + ':heatsink-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def voltage_set(self) -> 'DecopReal':
        return self._voltage_set

    @property
    def voltage_min(self) -> 'DecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'DecopReal':
        return self._voltage_max

    @property
    def voltage_set_dithering(self) -> 'DecopBoolean':
        return self._voltage_set_dithering

    @property
    def external_input(self) -> 'ExtInput3':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter3':
        return self._output_filter

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def feedforward_master(self) -> 'DecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'DecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'DecopReal':
        return self._feedforward_factor

    @property
    def heatsink_temp(self) -> 'DecopReal':
        return self._heatsink_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class OutputFilter3:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slew_rate = DecopReal(client, name + ':slew-rate')
        self._slew_rate_enabled = DecopBoolean(client, name + ':slew-rate-enabled')
        self._slew_rate_limited = DecopBoolean(client, name + ':slew-rate-limited')

    @property
    def slew_rate(self) -> 'DecopReal':
        return self._slew_rate

    @property
    def slew_rate_enabled(self) -> 'DecopBoolean':
        return self._slew_rate_enabled

    @property
    def slew_rate_limited(self) -> 'DecopBoolean':
        return self._slew_rate_limited


class UvCrystal:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._tc = TcChannel2(client, name + ':tc')
        self._optics_shifters = NloLaserHeadUvCrystalSpots(client, name + ':optics-shifters')

    @property
    def tc(self) -> 'TcChannel2':
        return self._tc

    @property
    def optics_shifters(self) -> 'NloLaserHeadUvCrystalSpots':
        return self._optics_shifters


class NloLaserHeadUvCrystalSpots:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._current_spot = DecopInteger(client, name + ':current-spot')
        self._remaining_spots = DecopInteger(client, name + ':remaining-spots')

    @property
    def current_spot(self) -> 'DecopInteger':
        return self._current_spot

    @property
    def remaining_spots(self) -> 'DecopInteger':
        return self._remaining_spots


class NloLaserHeadUvServos:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._shg1_hor = NloLaserHeadServoPwm2(client, name + ':shg1-hor')
        self._shg1_vert = NloLaserHeadServoPwm2(client, name + ':shg1-vert')
        self._shg2_hor = NloLaserHeadServoPwm2(client, name + ':shg2-hor')
        self._shg2_vert = NloLaserHeadServoPwm2(client, name + ':shg2-vert')
        self._hwp = NloLaserHeadServoPwm2(client, name + ':hwp')
        self._lens = NloLaserHeadServoPwm2(client, name + ':lens')
        self._outcpl = NloLaserHeadServoPwm2(client, name + ':outcpl')
        self._cryst = NloLaserHeadServoPwm2(client, name + ':cryst')
        self._comp_hor = NloLaserHeadServoPwm2(client, name + ':comp-hor')
        self._comp_vert = NloLaserHeadServoPwm2(client, name + ':comp-vert')

    @property
    def shg1_hor(self) -> 'NloLaserHeadServoPwm2':
        return self._shg1_hor

    @property
    def shg1_vert(self) -> 'NloLaserHeadServoPwm2':
        return self._shg1_vert

    @property
    def shg2_hor(self) -> 'NloLaserHeadServoPwm2':
        return self._shg2_hor

    @property
    def shg2_vert(self) -> 'NloLaserHeadServoPwm2':
        return self._shg2_vert

    @property
    def hwp(self) -> 'NloLaserHeadServoPwm2':
        return self._hwp

    @property
    def lens(self) -> 'NloLaserHeadServoPwm2':
        return self._lens

    @property
    def outcpl(self) -> 'NloLaserHeadServoPwm2':
        return self._outcpl

    @property
    def cryst(self) -> 'NloLaserHeadServoPwm2':
        return self._cryst

    @property
    def comp_hor(self) -> 'NloLaserHeadServoPwm2':
        return self._comp_hor

    @property
    def comp_vert(self) -> 'NloLaserHeadServoPwm2':
        return self._comp_vert


class NloLaserHeadServoPwm2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._display_name = DecopString(client, name + ':display-name')
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._value = DecopInteger(client, name + ':value')

    @property
    def display_name(self) -> 'DecopString':
        return self._display_name

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def value(self) -> 'DecopInteger':
        return self._value


class NloLaserHeadUvPhotoDiodes:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._shg = NloLaserHeadNloPhotodiode2(client, name + ':shg')
        self._pdh_rf = NloLaserHeadNloPdhPhotodiode2(client, name + ':pdh-rf')
        self._pdh_dc = NloLaserHeadNloDigilockPhotodiode2(client, name + ':pdh-dc')

    @property
    def shg(self) -> 'NloLaserHeadNloPhotodiode2':
        return self._shg

    @property
    def pdh_rf(self) -> 'NloLaserHeadNloPdhPhotodiode2':
        return self._pdh_rf

    @property
    def pdh_dc(self) -> 'NloLaserHeadNloDigilockPhotodiode2':
        return self._pdh_dc


class NloLaserHeadNloPhotodiode2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power = DecopReal(client, name + ':power')
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._cal_offset = DecopReal(client, name + ':cal-offset')
        self._cal_factor = DecopReal(client, name + ':cal-factor')

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def cal_offset(self) -> 'DecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'DecopReal':
        return self._cal_factor


class NloLaserHeadNloPdhPhotodiode2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._gain = DecopReal(client, name + ':gain')

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def gain(self) -> 'DecopReal':
        return self._gain


class NloLaserHeadNloDigilockPhotodiode2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._cal_offset = DecopReal(client, name + ':cal-offset')

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def cal_offset(self) -> 'DecopReal':
        return self._cal_offset


class UvShgPowerOptimization:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ongoing = DecopBoolean(client, name + ':ongoing')
        self._status = DecopInteger(client, name + ':status')
        self._status_string = DecopString(client, name + ':status-string')
        self._cavity = NloStage2(client, name + ':cavity')
        self._progress_data = DecopBinary(client, name + ':progress-data')
        self._abort = DecopBoolean(client, name + ':abort')

    @property
    def ongoing(self) -> 'DecopBoolean':
        return self._ongoing

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_string(self) -> 'DecopString':
        return self._status_string

    @property
    def cavity(self) -> 'NloStage2':
        return self._cavity

    @property
    def progress_data(self) -> 'DecopBinary':
        return self._progress_data

    @property
    def abort(self) -> 'DecopBoolean':
        return self._abort


class NloStage2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input = NloOptInput2(client, name + ':input')
        self._progress = DecopInteger(client, name + ':progress')
        self._optimization_allowed = DecopBoolean(client, name + ':optimization-allowed')
        self._optimization_in_progress = DecopBoolean(client, name + ':optimization-in-progress')
        self._restore_on_abort = DecopBoolean(client, name + ':restore-on-abort')
        self._restore_on_regress = DecopBoolean(client, name + ':restore-on-regress')
        self._regress_tolerance = DecopInteger(client, name + ':regress-tolerance')
        self._autosave_actuator_values = DecopBoolean(client, name + ':autosave-actuator-values')

    @property
    def input(self) -> 'NloOptInput2':
        return self._input

    @property
    def progress(self) -> 'DecopInteger':
        return self._progress

    @property
    def optimization_allowed(self) -> 'DecopBoolean':
        return self._optimization_allowed

    @property
    def optimization_in_progress(self) -> 'DecopBoolean':
        return self._optimization_in_progress

    @property
    def restore_on_abort(self) -> 'DecopBoolean':
        return self._restore_on_abort

    @property
    def restore_on_regress(self) -> 'DecopBoolean':
        return self._restore_on_regress

    @property
    def regress_tolerance(self) -> 'DecopInteger':
        return self._regress_tolerance

    @property
    def autosave_actuator_values(self) -> 'DecopBoolean':
        return self._autosave_actuator_values


class NloOptInput2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_calibrated = DecopReal(client, name + ':value-calibrated')

    @property
    def value_calibrated(self) -> 'DecopReal':
        return self._value_calibrated


class UvShgPowerStabilization:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._gain = PwrStabGain3(client, name + ':gain')
        self._power_set = DecopReal(client, name + ':power-set')
        self._power_act = DecopReal(client, name + ':power-act')
        self._power_min = DecopReal(client, name + ':power-min')
        self._power_max = DecopReal(client, name + ':power-max')
        self._state = DecopInteger(client, name + ':state')
        self._update_strategy = DecopInteger(client, name + ':update-strategy')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def gain(self) -> 'PwrStabGain3':
        return self._gain

    @property
    def power_set(self) -> 'DecopReal':
        return self._power_set

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act

    @property
    def power_min(self) -> 'DecopReal':
        return self._power_min

    @property
    def power_max(self) -> 'DecopReal':
        return self._power_max

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def update_strategy(self) -> 'DecopInteger':
        return self._update_strategy


class PwrStabGain3:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = DecopReal(client, name + ':all')
        self._p = DecopReal(client, name + ':p')
        self._i = DecopReal(client, name + ':i')
        self._d = DecopReal(client, name + ':d')

    @property
    def all(self) -> 'DecopReal':
        return self._all

    @property
    def p(self) -> 'DecopReal':
        return self._p

    @property
    def i(self) -> 'DecopReal':
        return self._i

    @property
    def d(self) -> 'DecopReal':
        return self._d


class UvShgOptimizationSettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._single_mode_optimization = MutableDecopBoolean(client, name + ':single-mode-optimization')

    @property
    def single_mode_optimization(self) -> 'MutableDecopBoolean':
        return self._single_mode_optimization


class NloLaserHeadSiggen2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._frequency = DecopReal(client, name + ':frequency')
        self._amplitude = DecopReal(client, name + ':amplitude')
        self._offset = DecopReal(client, name + ':offset')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def frequency(self) -> 'DecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'DecopReal':
        return self._amplitude

    @property
    def offset(self) -> 'DecopReal':
        return self._offset


class NloLaserHeadScopeT2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._variant = DecopInteger(client, name + ':variant')
        self._update_rate = DecopInteger(client, name + ':update-rate')
        self._channel1 = NloLaserHeadScopeChannelT2(client, name + ':channel1')
        self._channel2 = NloLaserHeadScopeChannelT2(client, name + ':channel2')
        self._channelx = NloLaserHeadScopeXAxisT2(client, name + ':channelx')
        self._timescale = DecopReal(client, name + ':timescale')
        self._data = DecopBinary(client, name + ':data')

    @property
    def variant(self) -> 'DecopInteger':
        return self._variant

    @property
    def update_rate(self) -> 'DecopInteger':
        return self._update_rate

    @property
    def channel1(self) -> 'NloLaserHeadScopeChannelT2':
        return self._channel1

    @property
    def channel2(self) -> 'NloLaserHeadScopeChannelT2':
        return self._channel2

    @property
    def channelx(self) -> 'NloLaserHeadScopeXAxisT2':
        return self._channelx

    @property
    def timescale(self) -> 'DecopReal':
        return self._timescale

    @property
    def data(self) -> 'DecopBinary':
        return self._data


class NloLaserHeadScopeChannelT2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = DecopInteger(client, name + ':signal')
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def signal(self) -> 'DecopInteger':
        return self._signal

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class NloLaserHeadScopeXAxisT2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._xy_signal = DecopInteger(client, name + ':xy-signal')
        self._scope_timescale = DecopReal(client, name + ':scope-timescale')
        self._spectrum_range = DecopReal(client, name + ':spectrum-range')
        self._spectrum_omit_dc = DecopBoolean(client, name + ':spectrum-omit-dc')
        self._unit = DecopString(client, name + ':unit')
        self._name = DecopString(client, name + ':name')

    @property
    def xy_signal(self) -> 'DecopInteger':
        return self._xy_signal

    @property
    def scope_timescale(self) -> 'DecopReal':
        return self._scope_timescale

    @property
    def spectrum_range(self) -> 'DecopReal':
        return self._spectrum_range

    @property
    def spectrum_omit_dc(self) -> 'DecopBoolean':
        return self._spectrum_omit_dc

    @property
    def unit(self) -> 'DecopString':
        return self._unit

    @property
    def name(self) -> 'DecopString':
        return self._name


class NloLaserHeadLockShg2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._state = DecopInteger(client, name + ':state')
        self._state_txt = DecopString(client, name + ':state-txt')
        self._lock_enabled = DecopBoolean(client, name + ':lock-enabled')
        self._pid_selection = DecopInteger(client, name + ':pid-selection')
        self._setpoint = DecopReal(client, name + ':setpoint')
        self._relock = NloLaserHeadRelock2(client, name + ':relock')
        self._window = NloLaserHeadWindow2(client, name + ':window')
        self._pid1 = NloLaserHeadPid2(client, name + ':pid1')
        self._pid2 = NloLaserHeadPid2(client, name + ':pid2')
        self._analog_dl_gain = NloLaserHeadMinifalc2(client, name + ':analog-dl-gain')
        self._local_oscillator = NloLaserHeadLocalOscillatorShg2(client, name + ':local-oscillator')
        self._cavity_fast_pzt_voltage = DecopReal(client, name + ':cavity-fast-pzt-voltage')
        self._cavity_slow_pzt_voltage = DecopReal(client, name + ':cavity-slow-pzt-voltage')
        self._background_trace = DecopBinary(client, name + ':background-trace')
        self._candidates = DecopBinary(client, name + ':candidates')

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def state_txt(self) -> 'DecopString':
        return self._state_txt

    @property
    def lock_enabled(self) -> 'DecopBoolean':
        return self._lock_enabled

    @property
    def pid_selection(self) -> 'DecopInteger':
        return self._pid_selection

    @property
    def setpoint(self) -> 'DecopReal':
        return self._setpoint

    @property
    def relock(self) -> 'NloLaserHeadRelock2':
        return self._relock

    @property
    def window(self) -> 'NloLaserHeadWindow2':
        return self._window

    @property
    def pid1(self) -> 'NloLaserHeadPid2':
        return self._pid1

    @property
    def pid2(self) -> 'NloLaserHeadPid2':
        return self._pid2

    @property
    def analog_dl_gain(self) -> 'NloLaserHeadMinifalc2':
        return self._analog_dl_gain

    @property
    def local_oscillator(self) -> 'NloLaserHeadLocalOscillatorShg2':
        return self._local_oscillator

    @property
    def cavity_fast_pzt_voltage(self) -> 'DecopReal':
        return self._cavity_fast_pzt_voltage

    @property
    def cavity_slow_pzt_voltage(self) -> 'DecopReal':
        return self._cavity_slow_pzt_voltage

    @property
    def background_trace(self) -> 'DecopBinary':
        return self._background_trace

    @property
    def candidates(self) -> 'DecopBinary':
        return self._candidates


class NloLaserHeadRelock2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._frequency = DecopReal(client, name + ':frequency')
        self._amplitude = DecopReal(client, name + ':amplitude')
        self._delay = DecopReal(client, name + ':delay')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def frequency(self) -> 'DecopReal':
        return self._frequency

    @property
    def amplitude(self) -> 'DecopReal':
        return self._amplitude

    @property
    def delay(self) -> 'DecopReal':
        return self._delay


class NloLaserHeadWindow2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_channel = DecopInteger(client, name + ':input-channel')
        self._threshold = DecopReal(client, name + ':threshold')
        self._level_hysteresis = DecopReal(client, name + ':level-hysteresis')
        self._calibration = NloLaserHeadWindowCalibration1(client, name + ':calibration')

    @property
    def input_channel(self) -> 'DecopInteger':
        return self._input_channel

    @property
    def threshold(self) -> 'DecopReal':
        return self._threshold

    @property
    def level_hysteresis(self) -> 'DecopReal':
        return self._level_hysteresis

    @property
    def calibration(self) -> 'NloLaserHeadWindowCalibration1':
        return self._calibration


class NloLaserHeadWindowCalibration1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power_min = DecopReal(client, name + ':power-min')
        self._power_max = DecopReal(client, name + ':power-max')
        self._threshold_min = DecopReal(client, name + ':threshold-min')
        self._threshold_max = DecopReal(client, name + ':threshold-max')

    @property
    def power_min(self) -> 'DecopReal':
        return self._power_min

    @property
    def power_max(self) -> 'DecopReal':
        return self._power_max

    @property
    def threshold_min(self) -> 'DecopReal':
        return self._threshold_min

    @property
    def threshold_max(self) -> 'DecopReal':
        return self._threshold_max


class NloLaserHeadPid2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._gain = NloLaserHeadGain2(client, name + ':gain')

    @property
    def gain(self) -> 'NloLaserHeadGain2':
        return self._gain


class NloLaserHeadGain2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = DecopReal(client, name + ':all')
        self._p = DecopReal(client, name + ':p')
        self._i = DecopReal(client, name + ':i')
        self._d = DecopReal(client, name + ':d')
        self._i_cutoff = DecopReal(client, name + ':i-cutoff')
        self._i_cutoff_enabled = DecopBoolean(client, name + ':i-cutoff-enabled')

    @property
    def all(self) -> 'DecopReal':
        return self._all

    @property
    def p(self) -> 'DecopReal':
        return self._p

    @property
    def i(self) -> 'DecopReal':
        return self._i

    @property
    def d(self) -> 'DecopReal':
        return self._d

    @property
    def i_cutoff(self) -> 'DecopReal':
        return self._i_cutoff

    @property
    def i_cutoff_enabled(self) -> 'DecopBoolean':
        return self._i_cutoff_enabled


class NloLaserHeadMinifalc2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._p_gain = DecopReal(client, name + ':p-gain')

    @property
    def p_gain(self) -> 'DecopReal':
        return self._p_gain


class NloLaserHeadLocalOscillatorShg2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._coupled_modulation = DecopBoolean(client, name + ':coupled-modulation')
        self._use_fast_oscillator = DecopBoolean(client, name + ':use-fast-oscillator')
        self._use_external_oscillator = DecopBoolean(client, name + ':use-external-oscillator')
        self._amplitude = DecopReal(client, name + ':amplitude')
        self._attenuation_raw = DecopInteger(client, name + ':attenuation-raw')
        self._phase_shift = DecopReal(client, name + ':phase-shift')
        self._auto_pdh_state = DecopInteger(client, name + ':auto-pdh-state')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def coupled_modulation(self) -> 'DecopBoolean':
        return self._coupled_modulation

    @property
    def use_fast_oscillator(self) -> 'DecopBoolean':
        return self._use_fast_oscillator

    @property
    def use_external_oscillator(self) -> 'DecopBoolean':
        return self._use_external_oscillator

    @property
    def amplitude(self) -> 'DecopReal':
        return self._amplitude

    @property
    def attenuation_raw(self) -> 'DecopInteger':
        return self._attenuation_raw

    @property
    def phase_shift(self) -> 'DecopReal':
        return self._phase_shift

    @property
    def auto_pdh_state(self) -> 'DecopInteger':
        return self._auto_pdh_state


class UvFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._eom_tc = NloLaserHeadTcFactorySettings(client, name + ':eom-tc')
        self._crystal_tc = NloLaserHeadTcFactorySettings(client, name + ':crystal-tc')
        self._cavity_tc = NloLaserHeadTcFactorySettings(client, name + ':cavity-tc')
        self._pc = NloLaserHeadPcFactorySettings(client, name + ':pc')
        self._pd = NloLaserHeadUvPhotodiodesFactorySettings(client, name + ':pd')
        self._lock = NloLaserHeadLockFactorySettings(client, name + ':lock')
        self._modified = DecopBoolean(client, name + ':modified')

    @property
    def eom_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._eom_tc

    @property
    def crystal_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._crystal_tc

    @property
    def cavity_tc(self) -> 'NloLaserHeadTcFactorySettings':
        return self._cavity_tc

    @property
    def pc(self) -> 'NloLaserHeadPcFactorySettings':
        return self._pc

    @property
    def pd(self) -> 'NloLaserHeadUvPhotodiodesFactorySettings':
        return self._pd

    @property
    def lock(self) -> 'NloLaserHeadLockFactorySettings':
        return self._lock

    @property
    def modified(self) -> 'DecopBoolean':
        return self._modified

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)

    def retrieve_now(self) -> None:
        self.__client.exec(self.__name + ':retrieve-now', input_stream=None, output_type=None, return_type=None)


class NloLaserHeadUvPhotodiodesFactorySettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._shg = NloLaserHeadPdFactorySettings1(client, name + ':shg')
        self._pdh_rf = NloLaserHeadPdPdhFactorySettings(client, name + ':pdh-rf')
        self._pdh_dc = NloLaserHeadPdDigilockFactorySettings(client, name + ':pdh-dc')

    @property
    def shg(self) -> 'NloLaserHeadPdFactorySettings1':
        return self._shg

    @property
    def pdh_rf(self) -> 'NloLaserHeadPdPdhFactorySettings':
        return self._pdh_rf

    @property
    def pdh_dc(self) -> 'NloLaserHeadPdDigilockFactorySettings':
        return self._pdh_dc


class UvStatusParameters:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._baseplate_temperature_limit = DecopReal(client, name + ':baseplate-temperature-limit')
        self._temperature_settle_time = DecopInteger(client, name + ':temperature-settle-time')
        self._pump_lock_settle_time = DecopInteger(client, name + ':pump-lock-settle-time')
        self._settle_down_delay = DecopInteger(client, name + ':settle-down-delay')
        self._power_margin_tolerance_time = DecopInteger(client, name + ':power-margin-tolerance-time')
        self._power_margin_threshold = DecopReal(client, name + ':power-margin-threshold')
        self._cavity_lock_settle_time = DecopInteger(client, name + ':cavity-lock-settle-time')
        self._cavity_lock_tolerance_factor = DecopInteger(client, name + ':cavity-lock-tolerance-factor')
        self._power_lock_settle_time = DecopInteger(client, name + ':power-lock-settle-time')
        self._cavity_scan_duration = DecopInteger(client, name + ':cavity-scan-duration')
        self._power_stabilization_strategy = DecopInteger(client, name + ':power-stabilization-strategy')
        self._power_stabilization_level_low_factor = DecopReal(client, name + ':power-stabilization-level-low-factor')
        self._power_output_relative_error_max = DecopReal(client, name + ':power-output-relative-error-max')
        self._power_output_relative_deviation_max = DecopReal(client, name + ':power-output-relative-deviation-max')
        self._operational_pump_power = DecopReal(client, name + ':operational-pump-power')
        self._degradation_detection_slope_threshold = DecopReal(client, name + ':degradation-detection-slope-threshold')
        self._degradation_detection_measurement_interval = DecopInteger(client, name + ':degradation-detection-measurement-interval')
        self._degradation_detection_number_of_measurements = DecopInteger(client, name + ':degradation-detection-number-of-measurements')
        self._idle_alignment_option = DecopBoolean(client, name + ':idle-alignment-option')

    @property
    def baseplate_temperature_limit(self) -> 'DecopReal':
        return self._baseplate_temperature_limit

    @property
    def temperature_settle_time(self) -> 'DecopInteger':
        return self._temperature_settle_time

    @property
    def pump_lock_settle_time(self) -> 'DecopInteger':
        return self._pump_lock_settle_time

    @property
    def settle_down_delay(self) -> 'DecopInteger':
        return self._settle_down_delay

    @property
    def power_margin_tolerance_time(self) -> 'DecopInteger':
        return self._power_margin_tolerance_time

    @property
    def power_margin_threshold(self) -> 'DecopReal':
        return self._power_margin_threshold

    @property
    def cavity_lock_settle_time(self) -> 'DecopInteger':
        return self._cavity_lock_settle_time

    @property
    def cavity_lock_tolerance_factor(self) -> 'DecopInteger':
        return self._cavity_lock_tolerance_factor

    @property
    def power_lock_settle_time(self) -> 'DecopInteger':
        return self._power_lock_settle_time

    @property
    def cavity_scan_duration(self) -> 'DecopInteger':
        return self._cavity_scan_duration

    @property
    def power_stabilization_strategy(self) -> 'DecopInteger':
        return self._power_stabilization_strategy

    @property
    def power_stabilization_level_low_factor(self) -> 'DecopReal':
        return self._power_stabilization_level_low_factor

    @property
    def power_output_relative_error_max(self) -> 'DecopReal':
        return self._power_output_relative_error_max

    @property
    def power_output_relative_deviation_max(self) -> 'DecopReal':
        return self._power_output_relative_deviation_max

    @property
    def operational_pump_power(self) -> 'DecopReal':
        return self._operational_pump_power

    @property
    def degradation_detection_slope_threshold(self) -> 'DecopReal':
        return self._degradation_detection_slope_threshold

    @property
    def degradation_detection_measurement_interval(self) -> 'DecopInteger':
        return self._degradation_detection_measurement_interval

    @property
    def degradation_detection_number_of_measurements(self) -> 'DecopInteger':
        return self._degradation_detection_number_of_measurements

    @property
    def idle_alignment_option(self) -> 'DecopBoolean':
        return self._idle_alignment_option


class PdExt:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._photodiode = DecopReal(client, name + ':photodiode')
        self._power = DecopReal(client, name + ':power')
        self._cal_offset = MutableDecopReal(client, name + ':cal-offset')
        self._cal_factor = MutableDecopReal(client, name + ':cal-factor')

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def photodiode(self) -> 'DecopReal':
        return self._photodiode

    @property
    def power(self) -> 'DecopReal':
        return self._power

    @property
    def cal_offset(self) -> 'MutableDecopReal':
        return self._cal_offset

    @property
    def cal_factor(self) -> 'MutableDecopReal':
        return self._cal_factor


class PwrStab:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._gain = PwrStabGain2(client, name + ':gain')
        self._sign = MutableDecopBoolean(client, name + ':sign')
        self._input_channel = MutableDecopInteger(client, name + ':input-channel')
        self._setpoint = MutableDecopReal(client, name + ':setpoint')
        self._window = PwrStabWindow(client, name + ':window')
        self._hold_output_on_unlock = MutableDecopBoolean(client, name + ':hold-output-on-unlock')
        self._output_channel = DecopInteger(client, name + ':output-channel')
        self._input_channel_value_act = DecopReal(client, name + ':input-channel-value-act')
        self._state = DecopInteger(client, name + ':state')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def gain(self) -> 'PwrStabGain2':
        return self._gain

    @property
    def sign(self) -> 'MutableDecopBoolean':
        return self._sign

    @property
    def input_channel(self) -> 'MutableDecopInteger':
        return self._input_channel

    @property
    def setpoint(self) -> 'MutableDecopReal':
        return self._setpoint

    @property
    def window(self) -> 'PwrStabWindow':
        return self._window

    @property
    def hold_output_on_unlock(self) -> 'MutableDecopBoolean':
        return self._hold_output_on_unlock

    @property
    def output_channel(self) -> 'DecopInteger':
        return self._output_channel

    @property
    def input_channel_value_act(self) -> 'DecopReal':
        return self._input_channel_value_act

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor


class PwrStabGain2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._p = MutableDecopReal(client, name + ':p')
        self._i = MutableDecopReal(client, name + ':i')
        self._d = MutableDecopReal(client, name + ':d')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def p(self) -> 'MutableDecopReal':
        return self._p

    @property
    def i(self) -> 'MutableDecopReal':
        return self._i

    @property
    def d(self) -> 'MutableDecopReal':
        return self._d


class PwrStabWindow:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._level_low = MutableDecopReal(client, name + ':level-low')
        self._level_hysteresis = MutableDecopReal(client, name + ':level-hysteresis')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def level_low(self) -> 'MutableDecopReal':
        return self._level_low

    @property
    def level_hysteresis(self) -> 'MutableDecopReal':
        return self._level_hysteresis


class LaserConfig:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._source = DecopString(client, name + ':source')
        self._product_name = DecopString(client, name + ':product-name')
        self._date = DecopString(client, name + ':date')
        self._caption = MutableDecopString(client, name + ':caption')
        self._pristine = DecopBoolean(client, name + ':pristine')

    @property
    def source(self) -> 'DecopString':
        return self._source

    @property
    def product_name(self) -> 'DecopString':
        return self._product_name

    @property
    def date(self) -> 'DecopString':
        return self._date

    @property
    def caption(self) -> 'MutableDecopString':
        return self._caption

    @property
    def pristine(self) -> 'DecopBoolean':
        return self._pristine

    def load(self, source: str) -> None:
        assert isinstance(source, str), f"expected type 'str' for parameter 'source', got '{type(source)}'"
        self.__client.exec(self.__name + ':load', source, input_stream=None, output_type=None, return_type=None)

    def save(self, destination: str) -> None:
        assert isinstance(destination, str), f"expected type 'str' for parameter 'destination', got '{type(destination)}'"
        self.__client.exec(self.__name + ':save', destination, input_stream=None, output_type=None, return_type=None)

    def import_(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        self.__client.exec(self.__name + ':import', input_stream=input_stream, output_type=None, return_type=None)

    def export(self) -> bytes:
        return self.__client.exec(self.__name + ':export', input_stream=None, output_type=bytes, return_type=None)

    def retrieve(self) -> None:
        self.__client.exec(self.__name + ':retrieve', input_stream=None, output_type=None, return_type=None)

    def apply(self) -> bool:
        return self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=bool)

    def show(self) -> str:
        return self.__client.exec(self.__name + ':show', input_stream=None, output_type=str, return_type=None)

    def list(self) -> str:
        return self.__client.exec(self.__name + ':list', input_stream=None, output_type=None, return_type=str)


class LaserDiagnosis:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ready = DecopBoolean(client, name + ':ready')
        self._options = LaserDiagnosisOptions(client, name + ':options')

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    @property
    def options(self) -> 'LaserDiagnosisOptions':
        return self._options

    def start(self) -> None:
        self.__client.exec(self.__name + ':start', input_stream=None, output_type=None, return_type=None)

    def print_result(self) -> bytes:
        return self.__client.exec(self.__name + ':print-result', input_stream=None, output_type=bytes, return_type=None)

    def execute(self) -> bytes:
        return self.__client.exec(self.__name + ':execute', input_stream=None, output_type=bytes, return_type=None)

    def generate_to_usb(self) -> None:
        self.__client.exec(self.__name + ':generate-to-usb', input_stream=None, output_type=None, return_type=None)


class LaserDiagnosisOptions:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._servo_test = MutableDecopBoolean(client, name + ':servo-test')
        self._servo_stepsize = MutableDecopInteger(client, name + ':servo-stepsize')
        self._motor_test = MutableDecopBoolean(client, name + ':motor-test')

    @property
    def servo_test(self) -> 'MutableDecopBoolean':
        return self._servo_test

    @property
    def servo_stepsize(self) -> 'MutableDecopInteger':
        return self._servo_stepsize

    @property
    def motor_test(self) -> 'MutableDecopBoolean':
        return self._motor_test


class LaserComponents:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name


class LaserCommon:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._scan = ScanSynchronization(client, name + ':scan')

    @property
    def scan(self) -> 'ScanSynchronization':
        return self._scan

    def save_all(self) -> None:
        self.__client.exec(self.__name + ':save-all', input_stream=None, output_type=None, return_type=None)

    def load_all(self) -> None:
        self.__client.exec(self.__name + ':load-all', input_stream=None, output_type=None, return_type=None)

    def store_all(self) -> None:
        self.__client.exec(self.__name + ':store-all', input_stream=None, output_type=None, return_type=None)

    def restore_all(self) -> None:
        self.__client.exec(self.__name + ':restore-all', input_stream=None, output_type=None, return_type=None)

    def apply_all(self) -> None:
        self.__client.exec(self.__name + ':apply-all', input_stream=None, output_type=None, return_type=None)

    def retrieve_all(self) -> None:
        self.__client.exec(self.__name + ':retrieve-all', input_stream=None, output_type=None, return_type=None)


class ScanSynchronization:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._sync_laser1 = MutableDecopBoolean(client, name + ':sync-laser1')
        self._sync_laser2 = MutableDecopBoolean(client, name + ':sync-laser2')
        self._frequency = MutableDecopReal(client, name + ':frequency')

    @property
    def sync_laser1(self) -> 'MutableDecopBoolean':
        return self._sync_laser1

    @property
    def sync_laser2(self) -> 'MutableDecopBoolean':
        return self._sync_laser2

    @property
    def frequency(self) -> 'MutableDecopReal':
        return self._frequency

    def sync(self) -> None:
        self.__client.exec(self.__name + ':sync', input_stream=None, output_type=None, return_type=None)

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class UvShgLaser:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._laser_on = MutableDecopBoolean(client, name + ':laser-on')
        self._emission = DecopBoolean(client, name + ':emission')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._specs_fulfilled = DecopBoolean(client, name + ':specs-fulfilled')
        self._error = DecopInteger(client, name + ':error')
        self._error_txt = DecopString(client, name + ':error-txt')
        self._operation_time_pump = DecopReal(client, name + ':operation-time-pump')
        self._operation_time_uv = DecopReal(client, name + ':operation-time-uv')
        self._pump_power_margin = DecopReal(client, name + ':pump-power-margin')
        self._remaining_optics_spots = DecopInteger(client, name + ':remaining-optics-spots')
        self._power_set = MutableDecopReal(client, name + ':power-set')
        self._power_act = DecopReal(client, name + ':power-act')
        self._baseplate_temperature = DecopReal(client, name + ':baseplate-temperature')
        self._idle_mode = MutableDecopBoolean(client, name + ':idle-mode')
        self._idle_alignment_option = MutableDecopBoolean(client, name + ':idle-alignment-option')
        self._optimization_settings = UvShgOptimizationSettings(client, name + ':optimization-settings')

    @property
    def laser_on(self) -> 'MutableDecopBoolean':
        return self._laser_on

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def specs_fulfilled(self) -> 'DecopBoolean':
        return self._specs_fulfilled

    @property
    def error(self) -> 'DecopInteger':
        return self._error

    @property
    def error_txt(self) -> 'DecopString':
        return self._error_txt

    @property
    def operation_time_pump(self) -> 'DecopReal':
        return self._operation_time_pump

    @property
    def operation_time_uv(self) -> 'DecopReal':
        return self._operation_time_uv

    @property
    def pump_power_margin(self) -> 'DecopReal':
        return self._pump_power_margin

    @property
    def remaining_optics_spots(self) -> 'DecopInteger':
        return self._remaining_optics_spots

    @property
    def power_set(self) -> 'MutableDecopReal':
        return self._power_set

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act

    @property
    def baseplate_temperature(self) -> 'DecopReal':
        return self._baseplate_temperature

    @property
    def idle_mode(self) -> 'MutableDecopBoolean':
        return self._idle_mode

    @property
    def idle_alignment_option(self) -> 'MutableDecopBoolean':
        return self._idle_alignment_option

    @property
    def optimization_settings(self) -> 'UvShgOptimizationSettings':
        return self._optimization_settings

    def perform_optimization(self) -> None:
        self.__client.exec(self.__name + ':perform-optimization', input_stream=None, output_type=None, return_type=None)

    def perform_optics_shift(self) -> None:
        self.__client.exec(self.__name + ':perform-optics-shift', input_stream=None, output_type=None, return_type=None)

    def clear_errors(self) -> None:
        self.__client.exec(self.__name + ':clear-errors', input_stream=None, output_type=None, return_type=None)


class AutoNloToplevel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._automatic_mode = MutableDecopBoolean(client, name + ':automatic-mode')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._laser_on = MutableDecopBoolean(client, name + ':laser-on')
        self._emission = DecopBoolean(client, name + ':emission')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._error = DecopInteger(client, name + ':error')
        self._error_txt = DecopString(client, name + ':error-txt')
        self._locked_cavity = DecopBoolean(client, name + ':locked-cavity')
        self._locked_cavity_fhg = DecopBoolean(client, name + ':locked-cavity-fhg')
        self._operation_time_master = DecopReal(client, name + ':operation-time-master')
        self._operation_time_amplifier = DecopReal(client, name + ':operation-time-amplifier')
        self._operation_time_cavity = DecopReal(client, name + ':operation-time-cavity')
        self._operation_time_cavity_fhg = DecopReal(client, name + ':operation-time-cavity-fhg')
        self._current_set_master = DecopReal(client, name + ':current-set-master')
        self._current_act_master = DecopReal(client, name + ':current-act-master')
        self._current_set_amplifier = DecopReal(client, name + ':current-set-amplifier')
        self._current_act_amplifier = DecopReal(client, name + ':current-act-amplifier')
        self._power_act_master = DecopReal(client, name + ':power-act-master')
        self._power_act_amplifier = DecopReal(client, name + ':power-act-amplifier')
        self._power_act_shg = DecopReal(client, name + ':power-act-shg')
        self._power_act_fhg = DecopReal(client, name + ':power-act-fhg')
        self._temp_set_master = DecopReal(client, name + ':temp-set-master')
        self._temp_act_master = DecopReal(client, name + ':temp-act-master')
        self._temp_set_amplifier = DecopReal(client, name + ':temp-set-amplifier')
        self._temp_act_amplifier = DecopReal(client, name + ':temp-act-amplifier')
        self._temp_set_crystal = MutableDecopReal(client, name + ':temp-set-crystal')
        self._temp_act_crystal = DecopReal(client, name + ':temp-act-crystal')
        self._temp_set_cavity = DecopReal(client, name + ':temp-set-cavity')
        self._temp_act_cavity = DecopReal(client, name + ':temp-act-cavity')
        self._temp_set_crystal_fhg = MutableDecopReal(client, name + ':temp-set-crystal-fhg')
        self._temp_act_crystal_fhg = DecopReal(client, name + ':temp-act-crystal-fhg')
        self._temp_set_cavity_fhg = DecopReal(client, name + ':temp-set-cavity-fhg')
        self._temp_act_cavity_fhg = DecopReal(client, name + ':temp-act-cavity-fhg')
        self._temp_act_baseplate = DecopReal(client, name + ':temp-act-baseplate')
        self._voltage_set_master = DecopReal(client, name + ':voltage-set-master')
        self._voltage_act_master = DecopReal(client, name + ':voltage-act-master')
        self._air_pressure = DecopReal(client, name + ':air-pressure')
        self._amplifier_current_margin = DecopReal(client, name + ':amplifier-current-margin')
        self._conversion_efficiency = DecopReal(client, name + ':conversion-efficiency')
        self._conversion_efficiency_fhg = DecopReal(client, name + ':conversion-efficiency-fhg')
        self._master_noise = DecopReal(client, name + ':master-noise')
        self._power_set = MutableDecopReal(client, name + ':power-set')
        self._power_act = DecopReal(client, name + ':power-act')
        self._wavelength = DecopReal(client, name + ':wavelength')
        self._idle_mode = MutableDecopBoolean(client, name + ':idle-mode')
        self._wavemeter = AutoNloWavemeter(client, name + ':wavemeter')
        self._power_stabilization_settings = AutoNloPowerStabilizationSettings(client, name + ':power-stabilization-settings')
        self._optimization_settings = AutoNloOptimizationOptions(client, name + ':optimization-settings')
        self._optimization_progress = DecopInteger(client, name + ':optimization-progress')
        self._last_time_auto_align = DecopString(client, name + ':last-time-auto-align')
        self._last_time_single_mode_optimization = DecopString(client, name + ':last-time-single-mode-optimization')
        self._single_mode_optimization_valid = DecopInteger(client, name + ':single-mode-optimization-valid')
        self._single_mode_algorithm = MutableDecopInteger(client, name + ':single-mode-algorithm')

    @property
    def automatic_mode(self) -> 'MutableDecopBoolean':
        return self._automatic_mode

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def laser_on(self) -> 'MutableDecopBoolean':
        return self._laser_on

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def error(self) -> 'DecopInteger':
        return self._error

    @property
    def error_txt(self) -> 'DecopString':
        return self._error_txt

    @property
    def locked_cavity(self) -> 'DecopBoolean':
        return self._locked_cavity

    @property
    def locked_cavity_fhg(self) -> 'DecopBoolean':
        return self._locked_cavity_fhg

    @property
    def operation_time_master(self) -> 'DecopReal':
        return self._operation_time_master

    @property
    def operation_time_amplifier(self) -> 'DecopReal':
        return self._operation_time_amplifier

    @property
    def operation_time_cavity(self) -> 'DecopReal':
        return self._operation_time_cavity

    @property
    def operation_time_cavity_fhg(self) -> 'DecopReal':
        return self._operation_time_cavity_fhg

    @property
    def current_set_master(self) -> 'DecopReal':
        return self._current_set_master

    @property
    def current_act_master(self) -> 'DecopReal':
        return self._current_act_master

    @property
    def current_set_amplifier(self) -> 'DecopReal':
        return self._current_set_amplifier

    @property
    def current_act_amplifier(self) -> 'DecopReal':
        return self._current_act_amplifier

    @property
    def power_act_master(self) -> 'DecopReal':
        return self._power_act_master

    @property
    def power_act_amplifier(self) -> 'DecopReal':
        return self._power_act_amplifier

    @property
    def power_act_shg(self) -> 'DecopReal':
        return self._power_act_shg

    @property
    def power_act_fhg(self) -> 'DecopReal':
        return self._power_act_fhg

    @property
    def temp_set_master(self) -> 'DecopReal':
        return self._temp_set_master

    @property
    def temp_act_master(self) -> 'DecopReal':
        return self._temp_act_master

    @property
    def temp_set_amplifier(self) -> 'DecopReal':
        return self._temp_set_amplifier

    @property
    def temp_act_amplifier(self) -> 'DecopReal':
        return self._temp_act_amplifier

    @property
    def temp_set_crystal(self) -> 'MutableDecopReal':
        return self._temp_set_crystal

    @property
    def temp_act_crystal(self) -> 'DecopReal':
        return self._temp_act_crystal

    @property
    def temp_set_cavity(self) -> 'DecopReal':
        return self._temp_set_cavity

    @property
    def temp_act_cavity(self) -> 'DecopReal':
        return self._temp_act_cavity

    @property
    def temp_set_crystal_fhg(self) -> 'MutableDecopReal':
        return self._temp_set_crystal_fhg

    @property
    def temp_act_crystal_fhg(self) -> 'DecopReal':
        return self._temp_act_crystal_fhg

    @property
    def temp_set_cavity_fhg(self) -> 'DecopReal':
        return self._temp_set_cavity_fhg

    @property
    def temp_act_cavity_fhg(self) -> 'DecopReal':
        return self._temp_act_cavity_fhg

    @property
    def temp_act_baseplate(self) -> 'DecopReal':
        return self._temp_act_baseplate

    @property
    def voltage_set_master(self) -> 'DecopReal':
        return self._voltage_set_master

    @property
    def voltage_act_master(self) -> 'DecopReal':
        return self._voltage_act_master

    @property
    def air_pressure(self) -> 'DecopReal':
        return self._air_pressure

    @property
    def amplifier_current_margin(self) -> 'DecopReal':
        return self._amplifier_current_margin

    @property
    def conversion_efficiency(self) -> 'DecopReal':
        return self._conversion_efficiency

    @property
    def conversion_efficiency_fhg(self) -> 'DecopReal':
        return self._conversion_efficiency_fhg

    @property
    def master_noise(self) -> 'DecopReal':
        return self._master_noise

    @property
    def power_set(self) -> 'MutableDecopReal':
        return self._power_set

    @property
    def power_act(self) -> 'DecopReal':
        return self._power_act

    @property
    def wavelength(self) -> 'DecopReal':
        return self._wavelength

    @property
    def idle_mode(self) -> 'MutableDecopBoolean':
        return self._idle_mode

    @property
    def wavemeter(self) -> 'AutoNloWavemeter':
        return self._wavemeter

    @property
    def power_stabilization_settings(self) -> 'AutoNloPowerStabilizationSettings':
        return self._power_stabilization_settings

    @property
    def optimization_settings(self) -> 'AutoNloOptimizationOptions':
        return self._optimization_settings

    @property
    def optimization_progress(self) -> 'DecopInteger':
        return self._optimization_progress

    @property
    def last_time_auto_align(self) -> 'DecopString':
        return self._last_time_auto_align

    @property
    def last_time_single_mode_optimization(self) -> 'DecopString':
        return self._last_time_single_mode_optimization

    @property
    def single_mode_optimization_valid(self) -> 'DecopInteger':
        return self._single_mode_optimization_valid

    @property
    def single_mode_algorithm(self) -> 'MutableDecopInteger':
        return self._single_mode_algorithm

    def perform_optimization(self) -> None:
        self.__client.exec(self.__name + ':perform-optimization', input_stream=None, output_type=None, return_type=None)

    def reset_operation_time_cavity(self) -> None:
        self.__client.exec(self.__name + ':reset-operation-time-cavity', input_stream=None, output_type=None, return_type=None)

    def reset_operation_time_cavity_fhg(self) -> None:
        self.__client.exec(self.__name + ':reset-operation-time-cavity-fhg', input_stream=None, output_type=None, return_type=None)

    def clear_errors(self) -> None:
        self.__client.exec(self.__name + ':clear-errors', input_stream=None, output_type=None, return_type=None)


class AutoNloPowerStabilizationSettings:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._power_min = MutableDecopReal(client, name + ':power-min')
        self._power_max = MutableDecopReal(client, name + ':power-max')
        self._amplifier_initial_current = MutableDecopReal(client, name + ':amplifier-initial-current')
        self._gain = PwrStabGain1(client, name + ':gain')

    @property
    def power_min(self) -> 'MutableDecopReal':
        return self._power_min

    @property
    def power_max(self) -> 'MutableDecopReal':
        return self._power_max

    @property
    def amplifier_initial_current(self) -> 'MutableDecopReal':
        return self._amplifier_initial_current

    @property
    def gain(self) -> 'PwrStabGain1':
        return self._gain


class PwrStabGain1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._p = MutableDecopReal(client, name + ':p')
        self._i = MutableDecopReal(client, name + ':i')
        self._d = MutableDecopReal(client, name + ':d')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def p(self) -> 'MutableDecopReal':
        return self._p

    @property
    def i(self) -> 'MutableDecopReal':
        return self._i

    @property
    def d(self) -> 'MutableDecopReal':
        return self._d


class AutoNloOptimizationOptions:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._pressure_compensation = MutableDecopBoolean(client, name + ':pressure-compensation')
        self._auto_align_amplifier = MutableDecopBoolean(client, name + ':auto-align-amplifier')
        self._auto_align_cavity = MutableDecopBoolean(client, name + ':auto-align-cavity')
        self._auto_align_include_advanced = MutableDecopBoolean(client, name + ':auto-align-include-advanced')
        self._single_mode_optimization = MutableDecopBoolean(client, name + ':single-mode-optimization')
        self._optimize_after_standby = MutableDecopBoolean(client, name + ':optimize-after-standby')

    @property
    def pressure_compensation(self) -> 'MutableDecopBoolean':
        return self._pressure_compensation

    @property
    def auto_align_amplifier(self) -> 'MutableDecopBoolean':
        return self._auto_align_amplifier

    @property
    def auto_align_cavity(self) -> 'MutableDecopBoolean':
        return self._auto_align_cavity

    @property
    def auto_align_include_advanced(self) -> 'MutableDecopBoolean':
        return self._auto_align_include_advanced

    @property
    def single_mode_optimization(self) -> 'MutableDecopBoolean':
        return self._single_mode_optimization

    @property
    def optimize_after_standby(self) -> 'MutableDecopBoolean':
        return self._optimize_after_standby


class CcBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slot = DecopString(client, name + ':slot')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._variant = DecopString(client, name + ':variant')
        self._parallel_mode = DecopBoolean(client, name + ':parallel-mode')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._channel1 = CurrDrv2(client, name + ':channel1')
        self._channel2 = CurrDrv2(client, name + ':channel2')

    @property
    def slot(self) -> 'DecopString':
        return self._slot

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def parallel_mode(self) -> 'DecopBoolean':
        return self._parallel_mode

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def channel1(self) -> 'CurrDrv2':
        return self._channel1

    @property
    def channel2(self) -> 'CurrDrv2':
        return self._channel2


class CurrDrv2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._variant = DecopString(client, name + ':variant')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._emission = DecopBoolean(client, name + ':emission')
        self._current_set = MutableDecopReal(client, name + ':current-set')
        self._current_offset = MutableDecopReal(client, name + ':current-offset')
        self._current_set_dithering = MutableDecopBoolean(client, name + ':current-set-dithering')
        self._external_input = ExtInput2(client, name + ':external-input')
        self._output_filter = OutputFilter2(client, name + ':output-filter')
        self._current_act = DecopReal(client, name + ':current-act')
        self._positive_polarity = MutableDecopBoolean(client, name + ':positive-polarity')
        self._current_clip = MutableDecopReal(client, name + ':current-clip')
        self._current_clip_tuning = DecopReal(client, name + ':current-clip-tuning')
        self._use_current_clip_tuning = MutableDecopBoolean(client, name + ':use-current-clip-tuning')
        self._current_clip_limit = DecopReal(client, name + ':current-clip-limit')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._voltage_clip = MutableDecopReal(client, name + ':voltage-clip')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._pd = DecopReal(client, name + ':pd')
        self._aux = DecopReal(client, name + ':aux')
        self._snubber = MutableDecopBoolean(client, name + ':snubber')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._forced_off = MutableDecopBoolean(client, name + ':forced-off')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def current_set(self) -> 'MutableDecopReal':
        return self._current_set

    @property
    def current_offset(self) -> 'MutableDecopReal':
        return self._current_offset

    @property
    def current_set_dithering(self) -> 'MutableDecopBoolean':
        return self._current_set_dithering

    @property
    def external_input(self) -> 'ExtInput2':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter2':
        return self._output_filter

    @property
    def current_act(self) -> 'DecopReal':
        return self._current_act

    @property
    def positive_polarity(self) -> 'MutableDecopBoolean':
        return self._positive_polarity

    @property
    def current_clip(self) -> 'MutableDecopReal':
        return self._current_clip

    @property
    def current_clip_tuning(self) -> 'DecopReal':
        return self._current_clip_tuning

    @property
    def use_current_clip_tuning(self) -> 'MutableDecopBoolean':
        return self._use_current_clip_tuning

    @property
    def current_clip_limit(self) -> 'DecopReal':
        return self._current_clip_limit

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def voltage_clip(self) -> 'MutableDecopReal':
        return self._voltage_clip

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def pd(self) -> 'DecopReal':
        return self._pd

    @property
    def aux(self) -> 'DecopReal':
        return self._aux

    @property
    def snubber(self) -> 'MutableDecopBoolean':
        return self._snubber

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def forced_off(self) -> 'MutableDecopBoolean':
        return self._forced_off


class ExtInput2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._signal = MutableDecopInteger(client, name + ':signal')
        self._factor = MutableDecopReal(client, name + ':factor')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')

    @property
    def signal(self) -> 'MutableDecopInteger':
        return self._signal

    @property
    def factor(self) -> 'MutableDecopReal':
        return self._factor

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled


class OutputFilter2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slew_rate = MutableDecopReal(client, name + ':slew-rate')
        self._slew_rate_enabled = MutableDecopBoolean(client, name + ':slew-rate-enabled')
        self._slew_rate_limited = DecopBoolean(client, name + ':slew-rate-limited')

    @property
    def slew_rate(self) -> 'MutableDecopReal':
        return self._slew_rate

    @property
    def slew_rate_enabled(self) -> 'MutableDecopBoolean':
        return self._slew_rate_enabled

    @property
    def slew_rate_limited(self) -> 'DecopBoolean':
        return self._slew_rate_limited


class Cc5000Board:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slot = DecopString(client, name + ':slot')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._variant = DecopString(client, name + ':variant')
        self._parallel_mode = DecopBoolean(client, name + ':parallel-mode')
        self._inverter_temp = DecopReal(client, name + ':inverter-temp')
        self._inverter_temp_fuse = DecopReal(client, name + ':inverter-temp-fuse')
        self._regulator_temp = DecopReal(client, name + ':regulator-temp')
        self._regulator_temp_fuse = DecopReal(client, name + ':regulator-temp-fuse')
        self._power_15v = MutableDecopBoolean(client, name + ':power-15v')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._channel1 = Cc5000Drv(client, name + ':channel1')

    @property
    def slot(self) -> 'DecopString':
        return self._slot

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def parallel_mode(self) -> 'DecopBoolean':
        return self._parallel_mode

    @property
    def inverter_temp(self) -> 'DecopReal':
        return self._inverter_temp

    @property
    def inverter_temp_fuse(self) -> 'DecopReal':
        return self._inverter_temp_fuse

    @property
    def regulator_temp(self) -> 'DecopReal':
        return self._regulator_temp

    @property
    def regulator_temp_fuse(self) -> 'DecopReal':
        return self._regulator_temp_fuse

    @property
    def power_15v(self) -> 'MutableDecopBoolean':
        return self._power_15v

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def channel1(self) -> 'Cc5000Drv':
        return self._channel1


class PcBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slot = DecopString(client, name + ':slot')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._variant = DecopString(client, name + ':variant')
        self._channel_count = DecopInteger(client, name + ':channel-count')
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._channel1 = PiezoDrv2(client, name + ':channel1')
        self._channel2 = PiezoDrv2(client, name + ':channel2')

    @property
    def slot(self) -> 'DecopString':
        return self._slot

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def variant(self) -> 'DecopString':
        return self._variant

    @property
    def channel_count(self) -> 'DecopInteger':
        return self._channel_count

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def channel1(self) -> 'PiezoDrv2':
        return self._channel1

    @property
    def channel2(self) -> 'PiezoDrv2':
        return self._channel2


class PiezoDrv2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._path = DecopString(client, name + ':path')
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._voltage_set = MutableDecopReal(client, name + ':voltage-set')
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._voltage_set_dithering = MutableDecopBoolean(client, name + ':voltage-set-dithering')
        self._external_input = ExtInput2(client, name + ':external-input')
        self._output_filter = OutputFilter2(client, name + ':output-filter')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._heatsink_temp = DecopReal(client, name + ':heatsink-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def path(self) -> 'DecopString':
        return self._path

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def voltage_set(self) -> 'MutableDecopReal':
        return self._voltage_set

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def voltage_set_dithering(self) -> 'MutableDecopBoolean':
        return self._voltage_set_dithering

    @property
    def external_input(self) -> 'ExtInput2':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter2':
        return self._output_filter

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def heatsink_temp(self) -> 'DecopReal':
        return self._heatsink_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class TcBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slot = DecopString(client, name + ':slot')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_fw_ver = DecopString(client, name + ':fpga-fw-ver')
        self._channel_count = DecopInteger(client, name + ':channel-count')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._channel1 = TcChannel1(client, name + ':channel1')
        self._channel1b = TcChannel1(client, name + ':channel1b')
        self._channel2 = TcChannel1(client, name + ':channel2')
        self._channel2b = TcChannel1(client, name + ':channel2b')

    @property
    def slot(self) -> 'DecopString':
        return self._slot

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_fw_ver(self) -> 'DecopString':
        return self._fpga_fw_ver

    @property
    def channel_count(self) -> 'DecopInteger':
        return self._channel_count

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def channel1(self) -> 'TcChannel1':
        return self._channel1

    @property
    def channel1b(self) -> 'TcChannel1':
        return self._channel1b

    @property
    def channel2(self) -> 'TcChannel1':
        return self._channel2

    @property
    def channel2b(self) -> 'TcChannel1':
        return self._channel2b


class McBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_type = DecopInteger(client, name + ':fpga-type')
        self._fpga_fw_ver = DecopString(client, name + ':fpga-fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._relative_humidity = DecopReal(client, name + ':relative-humidity')
        self._air_pressure = DecopReal(client, name + ':air-pressure')

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_type(self) -> 'DecopInteger':
        return self._fpga_type

    @property
    def fpga_fw_ver(self) -> 'DecopString':
        return self._fpga_fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def relative_humidity(self) -> 'DecopReal':
        return self._relative_humidity

    @property
    def air_pressure(self) -> 'DecopReal':
        return self._air_pressure


class IoBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._fine_1 = IoInputChannel(client, name + ':fine-1')
        self._fine_2 = IoInputChannel(client, name + ':fine-2')
        self._fast_3 = IoInputChannel(client, name + ':fast-3')
        self._fast_4 = IoInputChannel(client, name + ':fast-4')
        self._out_a = IoOutputChannel(client, name + ':out-a')
        self._out_b = IoOutputChannel(client, name + ':out-b')
        self._digital_in0 = IoDigitalInput(client, name + ':digital-in0')
        self._digital_in1 = IoDigitalInput(client, name + ':digital-in1')
        self._digital_in2 = IoDigitalInput(client, name + ':digital-in2')
        self._digital_in3 = IoDigitalInput(client, name + ':digital-in3')
        self._digital_out0 = IoDigitalOutput(client, name + ':digital-out0')
        self._digital_out1 = IoDigitalOutput(client, name + ':digital-out1')
        self._digital_out2 = IoDigitalOutput(client, name + ':digital-out2')
        self._digital_out3 = IoDigitalOutput(client, name + ':digital-out3')

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def fine_1(self) -> 'IoInputChannel':
        return self._fine_1

    @property
    def fine_2(self) -> 'IoInputChannel':
        return self._fine_2

    @property
    def fast_3(self) -> 'IoInputChannel':
        return self._fast_3

    @property
    def fast_4(self) -> 'IoInputChannel':
        return self._fast_4

    @property
    def out_a(self) -> 'IoOutputChannel':
        return self._out_a

    @property
    def out_b(self) -> 'IoOutputChannel':
        return self._out_b

    @property
    def digital_in0(self) -> 'IoDigitalInput':
        return self._digital_in0

    @property
    def digital_in1(self) -> 'IoDigitalInput':
        return self._digital_in1

    @property
    def digital_in2(self) -> 'IoDigitalInput':
        return self._digital_in2

    @property
    def digital_in3(self) -> 'IoDigitalInput':
        return self._digital_in3

    @property
    def digital_out0(self) -> 'IoDigitalOutput':
        return self._digital_out0

    @property
    def digital_out1(self) -> 'IoDigitalOutput':
        return self._digital_out1

    @property
    def digital_out2(self) -> 'IoDigitalOutput':
        return self._digital_out2

    @property
    def digital_out3(self) -> 'IoDigitalOutput':
        return self._digital_out3

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class IoInputChannel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_act = DecopReal(client, name + ':value-act')

    @property
    def value_act(self) -> 'DecopReal':
        return self._value_act


class IoOutputChannel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._voltage_set = MutableDecopReal(client, name + ':voltage-set')
        self._voltage_act = DecopReal(client, name + ':voltage-act')
        self._voltage_offset = MutableDecopReal(client, name + ':voltage-offset')
        self._voltage_enabled = MutableDecopBoolean(client, name + ':voltage-enabled')
        self._voltage_min = MutableDecopReal(client, name + ':voltage-min')
        self._voltage_max = MutableDecopReal(client, name + ':voltage-max')
        self._external_input = ExtInput1(client, name + ':external-input')
        self._output_filter = OutputFilter1(client, name + ':output-filter')
        self._linked_laser = MutableDecopInteger(client, name + ':linked-laser')
        self._feedforward_master = MutableDecopInteger(client, name + ':feedforward-master')
        self._feedforward_enabled = MutableDecopBoolean(client, name + ':feedforward-enabled')
        self._feedforward_factor = MutableDecopReal(client, name + ':feedforward-factor')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def voltage_set(self) -> 'MutableDecopReal':
        return self._voltage_set

    @property
    def voltage_act(self) -> 'DecopReal':
        return self._voltage_act

    @property
    def voltage_offset(self) -> 'MutableDecopReal':
        return self._voltage_offset

    @property
    def voltage_enabled(self) -> 'MutableDecopBoolean':
        return self._voltage_enabled

    @property
    def voltage_min(self) -> 'MutableDecopReal':
        return self._voltage_min

    @property
    def voltage_max(self) -> 'MutableDecopReal':
        return self._voltage_max

    @property
    def external_input(self) -> 'ExtInput1':
        return self._external_input

    @property
    def output_filter(self) -> 'OutputFilter1':
        return self._output_filter

    @property
    def linked_laser(self) -> 'MutableDecopInteger':
        return self._linked_laser

    @property
    def feedforward_master(self) -> 'MutableDecopInteger':
        return self._feedforward_master

    @property
    def feedforward_enabled(self) -> 'MutableDecopBoolean':
        return self._feedforward_enabled

    @property
    def feedforward_factor(self) -> 'MutableDecopReal':
        return self._feedforward_factor

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class IoDigitalInput:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_act = DecopBoolean(client, name + ':value-act')

    @property
    def value_act(self) -> 'DecopBoolean':
        return self._value_act


class IoDigitalOutput:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._value_act = DecopBoolean(client, name + ':value-act')
        self._value_set = MutableDecopBoolean(client, name + ':value-set')
        self._mode = MutableDecopInteger(client, name + ':mode')
        self._invert = MutableDecopBoolean(client, name + ':invert')

    @property
    def value_act(self) -> 'DecopBoolean':
        return self._value_act

    @property
    def value_set(self) -> 'MutableDecopBoolean':
        return self._value_set

    @property
    def mode(self) -> 'MutableDecopInteger':
        return self._mode

    @property
    def invert(self) -> 'MutableDecopBoolean':
        return self._invert


class PowerSupply:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._type = DecopString(client, name + ':type')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._heatsink_temp = DecopReal(client, name + ':heatsink-temp')
        self._current_5V = DecopReal(client, name + ':current-5V')
        self._current_15V = DecopReal(client, name + ':current-15V')
        self._current_15Vn = DecopReal(client, name + ':current-15Vn')
        self._voltage_5V = DecopReal(client, name + ':voltage-5V')
        self._voltage_15V = DecopReal(client, name + ':voltage-15V')
        self._voltage_15Vn = DecopReal(client, name + ':voltage-15Vn')
        self._voltage_3V3 = DecopReal(client, name + ':voltage-3V3')
        self._load = DecopReal(client, name + ':load')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def type(self) -> 'DecopString':
        return self._type

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def heatsink_temp(self) -> 'DecopReal':
        return self._heatsink_temp

    @property
    def current_5V(self) -> 'DecopReal':
        return self._current_5V

    @property
    def current_15V(self) -> 'DecopReal':
        return self._current_15V

    @property
    def current_15Vn(self) -> 'DecopReal':
        return self._current_15Vn

    @property
    def voltage_5V(self) -> 'DecopReal':
        return self._voltage_5V

    @property
    def voltage_15V(self) -> 'DecopReal':
        return self._voltage_15V

    @property
    def voltage_15Vn(self) -> 'DecopReal':
        return self._voltage_15Vn

    @property
    def voltage_3V3(self) -> 'DecopReal':
        return self._voltage_3V3

    @property
    def load(self) -> 'DecopReal':
        return self._load

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt


class Buzzer:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._welcome = MutableDecopString(client, name + ':welcome')
        self._sounds = BuzzerSounds(client, name + ':sounds')

    @property
    def welcome(self) -> 'MutableDecopString':
        return self._welcome

    @property
    def sounds(self) -> 'BuzzerSounds':
        return self._sounds

    def play_welcome(self) -> None:
        self.__client.exec(self.__name + ':play-welcome', input_stream=None, output_type=None, return_type=None)

    def play(self, melody: str) -> None:
        assert isinstance(melody, str), f"expected type 'str' for parameter 'melody', got '{type(melody)}'"
        self.__client.exec(self.__name + ':play', melody, input_stream=None, output_type=None, return_type=None)

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class BuzzerSounds:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._on_connection = MutableDecopBoolean(client, name + ':on-connection')

    @property
    def on_connection(self) -> 'MutableDecopBoolean':
        return self._on_connection


class Display:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._brightness = MutableDecopReal(client, name + ':brightness')
        self._auto_dark = MutableDecopBoolean(client, name + ':auto-dark')
        self._idle_timeout = MutableDecopInteger(client, name + ':idle-timeout')
        self._state = DecopInteger(client, name + ':state')

    @property
    def brightness(self) -> 'MutableDecopReal':
        return self._brightness

    @property
    def auto_dark(self) -> 'MutableDecopBoolean':
        return self._auto_dark

    @property
    def idle_timeout(self) -> 'MutableDecopInteger':
        return self._idle_timeout

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)

    def update_state(self, active: bool) -> None:
        assert isinstance(active, bool), f"expected type 'bool' for parameter 'active', got '{type(active)}'"
        self.__client.exec(self.__name + ':update-state', active, input_stream=None, output_type=None, return_type=None)


class Standby:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._state = DecopInteger(client, name + ':state')
        self._laser1 = StandbyLaser1(client, name + ':laser1')
        self._laser2 = StandbyLaser2(client, name + ':laser2')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def state(self) -> 'DecopInteger':
        return self._state

    @property
    def laser1(self) -> 'StandbyLaser1':
        return self._laser1

    @property
    def laser2(self) -> 'StandbyLaser2':
        return self._laser2


class StandbyLaser1:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._dl = StandbyDl(client, name + ':dl')
        self._amp = StandbyAmp(client, name + ':amp')
        self._ctl = StandbyCtl(client, name + ':ctl')
        self._nlo = StandbyShg(client, name + ':nlo')

    @property
    def dl(self) -> 'StandbyDl':
        return self._dl

    @property
    def amp(self) -> 'StandbyAmp':
        return self._amp

    @property
    def ctl(self) -> 'StandbyCtl':
        return self._ctl

    @property
    def nlo(self) -> 'StandbyShg':
        return self._nlo


class StandbyDl:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._disable_pc = MutableDecopBoolean(client, name + ':disable-pc')
        self._disable_cc = MutableDecopBoolean(client, name + ':disable-cc')
        self._disable_tc = MutableDecopBoolean(client, name + ':disable-tc')
        self._disable_eom = MutableDecopBoolean(client, name + ':disable-eom')

    @property
    def disable_pc(self) -> 'MutableDecopBoolean':
        return self._disable_pc

    @property
    def disable_cc(self) -> 'MutableDecopBoolean':
        return self._disable_cc

    @property
    def disable_tc(self) -> 'MutableDecopBoolean':
        return self._disable_tc

    @property
    def disable_eom(self) -> 'MutableDecopBoolean':
        return self._disable_eom


class StandbyAmp:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._disable_cc = MutableDecopBoolean(client, name + ':disable-cc')
        self._disable_tc = MutableDecopBoolean(client, name + ':disable-tc')

    @property
    def disable_cc(self) -> 'MutableDecopBoolean':
        return self._disable_cc

    @property
    def disable_tc(self) -> 'MutableDecopBoolean':
        return self._disable_tc


class StandbyCtl:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._disable = MutableDecopBoolean(client, name + ':disable')

    @property
    def disable(self) -> 'MutableDecopBoolean':
        return self._disable


class StandbyShg:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._disable_pc = MutableDecopBoolean(client, name + ':disable-pc')
        self._disable_tc = MutableDecopBoolean(client, name + ':disable-tc')
        self._disable_servo_subsystem = MutableDecopBoolean(client, name + ':disable-servo-subsystem')
        self._disable_power_stabilization = MutableDecopBoolean(client, name + ':disable-power-stabilization')
        self._disable_cavity_lock = MutableDecopBoolean(client, name + ':disable-cavity-lock')

    @property
    def disable_pc(self) -> 'MutableDecopBoolean':
        return self._disable_pc

    @property
    def disable_tc(self) -> 'MutableDecopBoolean':
        return self._disable_tc

    @property
    def disable_servo_subsystem(self) -> 'MutableDecopBoolean':
        return self._disable_servo_subsystem

    @property
    def disable_power_stabilization(self) -> 'MutableDecopBoolean':
        return self._disable_power_stabilization

    @property
    def disable_cavity_lock(self) -> 'MutableDecopBoolean':
        return self._disable_cavity_lock


class StandbyLaser2:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._dl = StandbyDl(client, name + ':dl')
        self._amp = StandbyAmp(client, name + ':amp')

    @property
    def dl(self) -> 'StandbyDl':
        return self._dl

    @property
    def amp(self) -> 'StandbyAmp':
        return self._amp


class PdhBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._slot = DecopString(client, name + ':slot')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fpga_fw_ver = DecopInteger(client, name + ':fpga-fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._channel1 = PdhChannel(client, name + ':channel1')
        self._channel2 = PdhChannel(client, name + ':channel2')

    @property
    def slot(self) -> 'DecopString':
        return self._slot

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fpga_fw_ver(self) -> 'DecopInteger':
        return self._fpga_fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def channel1(self) -> 'PdhChannel':
        return self._channel1

    @property
    def channel2(self) -> 'PdhChannel':
        return self._channel2

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class PdhChannel:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._modulation_enabled = MutableDecopBoolean(client, name + ':modulation-enabled')
        self._use_fast_oscillator = MutableDecopBoolean(client, name + ':use-fast-oscillator')
        self._modulation_amplitude_dbm = MutableDecopReal(client, name + ':modulation-amplitude-dbm')
        self._modulation_amplitude_vpp = DecopReal(client, name + ':modulation-amplitude-vpp')
        self._lo_output_amplitude_dbm = MutableDecopReal(client, name + ':lo-output-amplitude-dbm')
        self._lo_output_amplitude_vpp = DecopReal(client, name + ':lo-output-amplitude-vpp')
        self._lo_output_enabled = MutableDecopBoolean(client, name + ':lo-output-enabled')
        self._phase_shift = MutableDecopReal(client, name + ':phase-shift')
        self._input_level_max = MutableDecopInteger(client, name + ':input-level-max')
        self._lock_level = MutableDecopReal(client, name + ':lock-level')
        self._auto_pdh = AutoLir(client, name + ':auto-pdh')

    @property
    def modulation_enabled(self) -> 'MutableDecopBoolean':
        return self._modulation_enabled

    @property
    def use_fast_oscillator(self) -> 'MutableDecopBoolean':
        return self._use_fast_oscillator

    @property
    def modulation_amplitude_dbm(self) -> 'MutableDecopReal':
        return self._modulation_amplitude_dbm

    @property
    def modulation_amplitude_vpp(self) -> 'DecopReal':
        return self._modulation_amplitude_vpp

    @property
    def lo_output_amplitude_dbm(self) -> 'MutableDecopReal':
        return self._lo_output_amplitude_dbm

    @property
    def lo_output_amplitude_vpp(self) -> 'DecopReal':
        return self._lo_output_amplitude_vpp

    @property
    def lo_output_enabled(self) -> 'MutableDecopBoolean':
        return self._lo_output_enabled

    @property
    def phase_shift(self) -> 'MutableDecopReal':
        return self._phase_shift

    @property
    def input_level_max(self) -> 'MutableDecopInteger':
        return self._input_level_max

    @property
    def lock_level(self) -> 'MutableDecopReal':
        return self._lock_level

    @property
    def auto_pdh(self) -> 'AutoLir':
        return self._auto_pdh


class DigifalcBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._node_id = DecopInteger(client, name + ':node-id')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._label = DecopString(client, name + ':label')
        self._model = DecopInteger(client, name + ':model')
        self._revision = DecopString(client, name + ':revision')
        self._fw_ver = DecopString(client, name + ':fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._input = DigifalcInput(client, name + ':input')
        self._error = DigifalcError(client, name + ':error')
        self._mon = DigifalcMon(client, name + ':mon')
        self._unlim = DigifalcUnlim(client, name + ':unlim')
        self._main = DigifalcMain(client, name + ':main')
        self._path_selection = MutableDecopInteger(client, name + ':path-selection')
        self._hold_state = DecopBoolean(client, name + ':hold-state')

    @property
    def node_id(self) -> 'DecopInteger':
        return self._node_id

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def label(self) -> 'DecopString':
        return self._label

    @property
    def model(self) -> 'DecopInteger':
        return self._model

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def input(self) -> 'DigifalcInput':
        return self._input

    @property
    def error(self) -> 'DigifalcError':
        return self._error

    @property
    def mon(self) -> 'DigifalcMon':
        return self._mon

    @property
    def unlim(self) -> 'DigifalcUnlim':
        return self._unlim

    @property
    def main(self) -> 'DigifalcMain':
        return self._main

    @property
    def path_selection(self) -> 'MutableDecopInteger':
        return self._path_selection

    @property
    def hold_state(self) -> 'DecopBoolean':
        return self._hold_state

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class DigifalcInput:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._gain = MutableDecopInteger(client, name + ':gain')
        self._offset = MutableDecopReal(client, name + ':offset')

    @property
    def gain(self) -> 'MutableDecopInteger':
        return self._gain

    @property
    def offset(self) -> 'MutableDecopReal':
        return self._offset


class DigifalcError:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name


class DigifalcMon:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._config = MutableDecopInteger(client, name + ':config')

    @property
    def config(self) -> 'MutableDecopInteger':
        return self._config


class DigifalcUnlim:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._hold = MutableDecopBoolean(client, name + ':hold')
        self._sign = MutableDecopBoolean(client, name + ':sign')
        self._slew_rate = MutableDecopInteger(client, name + ':slew-rate')
        self._gain = DecopReal(client, name + ':gain')
        self._output_range = MutableDecopReal(client, name + ':output-range')
        self._input_offset = MutableDecopReal(client, name + ':input-offset')
        self._lock_state = DecopBoolean(client, name + ':lock-state')
        self._hold_state = DecopBoolean(client, name + ':hold-state')
        self._regulating_state = DecopBoolean(client, name + ':regulating-state')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def hold(self) -> 'MutableDecopBoolean':
        return self._hold

    @property
    def sign(self) -> 'MutableDecopBoolean':
        return self._sign

    @property
    def slew_rate(self) -> 'MutableDecopInteger':
        return self._slew_rate

    @property
    def gain(self) -> 'DecopReal':
        return self._gain

    @property
    def output_range(self) -> 'MutableDecopReal':
        return self._output_range

    @property
    def input_offset(self) -> 'MutableDecopReal':
        return self._input_offset

    @property
    def lock_state(self) -> 'DecopBoolean':
        return self._lock_state

    @property
    def hold_state(self) -> 'DecopBoolean':
        return self._hold_state

    @property
    def regulating_state(self) -> 'DecopBoolean':
        return self._regulating_state


class DigifalcMain:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = MutableDecopBoolean(client, name + ':enabled')
        self._gain = DigifalcMainGain(client, name + ':gain')
        self._lock_state = DecopBoolean(client, name + ':lock-state')

    @property
    def enabled(self) -> 'MutableDecopBoolean':
        return self._enabled

    @property
    def gain(self) -> 'DigifalcMainGain':
        return self._gain

    @property
    def lock_state(self) -> 'DecopBoolean':
        return self._lock_state


class DigifalcMainGain:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._all = MutableDecopReal(client, name + ':all')
        self._use_external_input = MutableDecopBoolean(client, name + ':use-external-input')
        self._i1_enabled = MutableDecopBoolean(client, name + ':i1-enabled')
        self._i1 = MutableDecopInteger(client, name + ':i1')
        self._i2_enabled = MutableDecopBoolean(client, name + ':i2-enabled')
        self._i2 = MutableDecopInteger(client, name + ':i2')
        self._i3_enabled = MutableDecopBoolean(client, name + ':i3-enabled')
        self._i3 = MutableDecopInteger(client, name + ':i3')
        self._d1_enabled = MutableDecopBoolean(client, name + ':d1-enabled')
        self._d1 = MutableDecopInteger(client, name + ':d1')
        self._d2_enabled = MutableDecopBoolean(client, name + ':d2-enabled')
        self._d2 = MutableDecopInteger(client, name + ':d2')
        self._ramp_up_rate = MutableDecopInteger(client, name + ':ramp-up-rate')

    @property
    def all(self) -> 'MutableDecopReal':
        return self._all

    @property
    def use_external_input(self) -> 'MutableDecopBoolean':
        return self._use_external_input

    @property
    def i1_enabled(self) -> 'MutableDecopBoolean':
        return self._i1_enabled

    @property
    def i1(self) -> 'MutableDecopInteger':
        return self._i1

    @property
    def i2_enabled(self) -> 'MutableDecopBoolean':
        return self._i2_enabled

    @property
    def i2(self) -> 'MutableDecopInteger':
        return self._i2

    @property
    def i3_enabled(self) -> 'MutableDecopBoolean':
        return self._i3_enabled

    @property
    def i3(self) -> 'MutableDecopInteger':
        return self._i3

    @property
    def d1_enabled(self) -> 'MutableDecopBoolean':
        return self._d1_enabled

    @property
    def d1(self) -> 'MutableDecopInteger':
        return self._d1

    @property
    def d2_enabled(self) -> 'MutableDecopBoolean':
        return self._d2_enabled

    @property
    def d2(self) -> 'MutableDecopInteger':
        return self._d2

    @property
    def ramp_up_rate(self) -> 'MutableDecopInteger':
        return self._ramp_up_rate


class ServoControlBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._node_id = DecopInteger(client, name + ':node-id')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fw_ver = DecopString(client, name + ':fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')

    @property
    def node_id(self) -> 'DecopInteger':
        return self._node_id

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    def save(self) -> None:
        self.__client.exec(self.__name + ':save', input_stream=None, output_type=None, return_type=None)

    def load(self) -> None:
        self.__client.exec(self.__name + ':load', input_stream=None, output_type=None, return_type=None)


class DlMotorBoard:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._node_id = DecopInteger(client, name + ':node-id')
        self._serial_number = DecopString(client, name + ':serial-number')
        self._revision = DecopString(client, name + ':revision')
        self._fw_ver = DecopString(client, name + ':fw-ver')
        self._board_temp = DecopReal(client, name + ':board-temp')
        self._status = DecopInteger(client, name + ':status')
        self._status_txt = DecopString(client, name + ':status-txt')
        self._channel1 = DlMotorStepper(client, name + ':channel1')
        self._channel2 = DlMotorStepper(client, name + ':channel2')

    @property
    def node_id(self) -> 'DecopInteger':
        return self._node_id

    @property
    def serial_number(self) -> 'DecopString':
        return self._serial_number

    @property
    def revision(self) -> 'DecopString':
        return self._revision

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver

    @property
    def board_temp(self) -> 'DecopReal':
        return self._board_temp

    @property
    def status(self) -> 'DecopInteger':
        return self._status

    @property
    def status_txt(self) -> 'DecopString':
        return self._status_txt

    @property
    def channel1(self) -> 'DlMotorStepper':
        return self._channel1

    @property
    def channel2(self) -> 'DlMotorStepper':
        return self._channel2


class SystemMessages:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._count = DecopInteger(client, name + ':count')
        self._count_new = DecopInteger(client, name + ':count-new')
        self._latest_message = DecopString(client, name + ':latest-message')

    @property
    def count(self) -> 'DecopInteger':
        return self._count

    @property
    def count_new(self) -> 'DecopInteger':
        return self._count_new

    @property
    def latest_message(self) -> 'DecopString':
        return self._latest_message

    def mark_as_read(self, id_: int) -> None:
        assert isinstance(id_, int), f"expected type 'int' for parameter 'id_', got '{type(id_)}'"
        self.__client.exec(self.__name + ':mark-as-read', id_, input_stream=None, output_type=None, return_type=None)

    def show_all(self) -> str:
        return self.__client.exec(self.__name + ':show-all', input_stream=None, output_type=str, return_type=None)

    def show_new(self) -> str:
        return self.__client.exec(self.__name + ':show-new', input_stream=None, output_type=str, return_type=None)

    def show_log(self) -> str:
        return self.__client.exec(self.__name + ':show-log', input_stream=None, output_type=str, return_type=None)

    def show_persistent(self) -> str:
        return self.__client.exec(self.__name + ':show-persistent', input_stream=None, output_type=str, return_type=None)


class Licenses:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._options = LicenseOptions(client, name + ':options')
        self._installed_keys = DecopInteger(client, name + ':installed-keys')

    @property
    def options(self) -> 'LicenseOptions':
        return self._options

    @property
    def installed_keys(self) -> 'DecopInteger':
        return self._installed_keys

    def get_key(self, key_number: int) -> str:
        assert isinstance(key_number, int), f"expected type 'int' for parameter 'key_number', got '{type(key_number)}'"
        return self.__client.exec(self.__name + ':get-key', key_number, input_stream=None, output_type=None, return_type=str)

    def install(self, licensekey: str) -> bool:
        assert isinstance(licensekey, str), f"expected type 'str' for parameter 'licensekey', got '{type(licensekey)}'"
        return self.__client.exec(self.__name + ':install', licensekey, input_stream=None, output_type=None, return_type=bool)


class LicenseOptions:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._lock = LicenseOption(client, name + ':lock')
        self._dual_laser_operation = LicenseOption(client, name + ':dual-laser-operation')
        self._quad_laser_operation = LicenseOption(client, name + ':quad-laser-operation')
        self._automatic_nlo_operation = LicenseOption(client, name + ':automatic-nlo-operation')

    @property
    def lock(self) -> 'LicenseOption':
        return self._lock

    @property
    def dual_laser_operation(self) -> 'LicenseOption':
        return self._dual_laser_operation

    @property
    def quad_laser_operation(self) -> 'LicenseOption':
        return self._quad_laser_operation

    @property
    def automatic_nlo_operation(self) -> 'LicenseOption':
        return self._automatic_nlo_operation


class LicenseOption:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._enabled = DecopBoolean(client, name + ':enabled')
        self._licensee = DecopString(client, name + ':licensee')
        self._valid_until = DecopString(client, name + ':valid-until')

    @property
    def enabled(self) -> 'DecopBoolean':
        return self._enabled

    @property
    def licensee(self) -> 'DecopString':
        return self._licensee

    @property
    def valid_until(self) -> 'DecopString':
        return self._valid_until


class FwUpdate:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name

    def upload(self, input_stream: bytes, filename: str) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        assert isinstance(filename, str), f"expected type 'str' for parameter 'filename', got '{type(filename)}'"
        self.__client.exec(self.__name + ':upload', filename, input_stream=input_stream, output_type=None, return_type=None)

    def show_log(self) -> str:
        return self.__client.exec(self.__name + ':show-log', input_stream=None, output_type=str, return_type=None)

    def show_history(self) -> str:
        return self.__client.exec(self.__name + ':show-history', input_stream=None, output_type=str, return_type=None)


class ServiceReport:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ready = DecopBoolean(client, name + ':ready')

    @property
    def ready(self) -> 'DecopBoolean':
        return self._ready

    def service_report(self) -> bytes:
        return self.__client.exec(self.__name + ':service-report', input_stream=None, output_type=bytes, return_type=None)

    def request(self) -> None:
        self.__client.exec(self.__name + ':request', input_stream=None, output_type=None, return_type=None)

    def add_info(self, text: str) -> None:
        assert isinstance(text, str), f"expected type 'str' for parameter 'text', got '{type(text)}'"
        self.__client.exec(self.__name + ':add-info', text, input_stream=None, output_type=None, return_type=None)

    def print(self) -> bytes:
        return self.__client.exec(self.__name + ':print', input_stream=None, output_type=bytes, return_type=None)

    def save_to_usb(self) -> None:
        self.__client.exec(self.__name + ':save-to-usb', input_stream=None, output_type=None, return_type=None)


class BuildInformation:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._build_number = DecopInteger(client, name + ':build-number')
        self._build_id = DecopString(client, name + ':build-id')
        self._build_tag = DecopString(client, name + ':build-tag')
        self._job_name = DecopString(client, name + ':job-name')
        self._build_node_name = DecopString(client, name + ':build-node-name')
        self._build_url = DecopString(client, name + ':build-url')
        self._cxx_compiler_version = DecopString(client, name + ':cxx-compiler-version')
        self._c_compiler_version = DecopString(client, name + ':c-compiler-version')
        self._cxx_compiler_id = DecopString(client, name + ':cxx-compiler-id')
        self._c_compiler_id = DecopString(client, name + ':c-compiler-id')

    @property
    def build_number(self) -> 'DecopInteger':
        return self._build_number

    @property
    def build_id(self) -> 'DecopString':
        return self._build_id

    @property
    def build_tag(self) -> 'DecopString':
        return self._build_tag

    @property
    def job_name(self) -> 'DecopString':
        return self._job_name

    @property
    def build_node_name(self) -> 'DecopString':
        return self._build_node_name

    @property
    def build_url(self) -> 'DecopString':
        return self._build_url

    @property
    def cxx_compiler_version(self) -> 'DecopString':
        return self._cxx_compiler_version

    @property
    def c_compiler_version(self) -> 'DecopString':
        return self._c_compiler_version

    @property
    def cxx_compiler_id(self) -> 'DecopString':
        return self._cxx_compiler_id

    @property
    def c_compiler_id(self) -> 'DecopString':
        return self._c_compiler_id


class Ipconfig:
    def __init__(self, client: Client, name: str) -> None:
        self.__client = client
        self.__name = name
        self._ip_addr = DecopString(client, name + ':ip-addr')
        self._net_mask = DecopString(client, name + ':net-mask')
        self._gateway = DecopString(client, name + ':gateway')
        self._hostname = DecopString(client, name + ':hostname')
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
    def gateway(self) -> 'DecopString':
        return self._gateway

    @property
    def hostname(self) -> 'DecopString':
        return self._hostname

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

    def set_ip_gateway(self, ip_addr: str, net_mask: str, gateway: str) -> None:
        assert isinstance(ip_addr, str), f"expected type 'str' for parameter 'ip_addr', got '{type(ip_addr)}'"
        assert isinstance(net_mask, str), f"expected type 'str' for parameter 'net_mask', got '{type(net_mask)}'"
        assert isinstance(gateway, str), f"expected type 'str' for parameter 'gateway', got '{type(gateway)}'"
        self.__client.exec(self.__name + ':set-ip-gateway', ip_addr, net_mask, gateway, input_stream=None, output_type=None, return_type=None)

    def apply(self) -> None:
        self.__client.exec(self.__name + ':apply', input_stream=None, output_type=None, return_type=None)


class DLCpro:
    def __init__(self, connection: Connection) -> None:
        self.__client = Client(connection)
        self._emission_button_enabled = MutableDecopBoolean(self.__client, 'emission-button-enabled')
        self._interlock_open = DecopBoolean(self.__client, 'interlock-open')
        self._frontkey_locked = DecopBoolean(self.__client, 'frontkey-locked')
        self._emission = DecopBoolean(self.__client, 'emission')
        self._system_health = DecopInteger(self.__client, 'system-health')
        self._system_health_txt = DecopString(self.__client, 'system-health-txt')
        self._laser1 = Laser(self.__client, 'laser1')
        self._laser2 = Laser(self.__client, 'laser2')
        self._laser_common = LaserCommon(self.__client, 'laser-common')
        self._uv = UvShgLaser(self.__client, 'uv')
        self._auto_nlo = AutoNloToplevel(self.__client, 'auto-nlo')
        self._cc1 = CcBoard(self.__client, 'cc1')
        self._cc2 = CcBoard(self.__client, 'cc2')
        self._ampcc1 = Cc5000Board(self.__client, 'ampcc1')
        self._ampcc2 = Cc5000Board(self.__client, 'ampcc2')
        self._pc1 = PcBoard(self.__client, 'pc1')
        self._pc2 = PcBoard(self.__client, 'pc2')
        self._pc3 = PcBoard(self.__client, 'pc3')
        self._tc1 = TcBoard(self.__client, 'tc1')
        self._tc2 = TcBoard(self.__client, 'tc2')
        self._mc = McBoard(self.__client, 'mc')
        self._io = IoBoard(self.__client, 'io')
        self._power_supply = PowerSupply(self.__client, 'power-supply')
        self._buzzer = Buzzer(self.__client, 'buzzer')
        self._display = Display(self.__client, 'display')
        self._standby = Standby(self.__client, 'standby')
        self._pdh1 = PdhBoard(self.__client, 'pdh1')
        self._falc1 = DigifalcBoard(self.__client, 'falc1')
        self._falc2 = DigifalcBoard(self.__client, 'falc2')
        self._falc3 = DigifalcBoard(self.__client, 'falc3')
        self._falc4 = DigifalcBoard(self.__client, 'falc4')
        self._servo_control1 = ServoControlBoard(self.__client, 'servo-control1')
        self._servo_control2 = ServoControlBoard(self.__client, 'servo-control2')
        self._servo_control3 = ServoControlBoard(self.__client, 'servo-control3')
        self._servo_control4 = ServoControlBoard(self.__client, 'servo-control4')
        self._mot1 = DlMotorBoard(self.__client, 'mot1')
        self._mot2 = DlMotorBoard(self.__client, 'mot2')
        self._time = MutableDecopString(self.__client, 'time')
        self._tan = DecopInteger(self.__client, 'tan')
        self._system_messages = SystemMessages(self.__client, 'system-messages')
        self._licenses = Licenses(self.__client, 'licenses')
        self._fw_update = FwUpdate(self.__client, 'fw-update')
        self._system_service_report = ServiceReport(self.__client, 'system-service-report')
        self._uptime = DecopInteger(self.__client, 'uptime')
        self._uptime_txt = DecopString(self.__client, 'uptime-txt')
        self._fw_ver = DecopString(self.__client, 'fw-ver')
        self._ssw_ver = DecopString(self.__client, 'ssw-ver')
        self._decof_ver = DecopString(self.__client, 'decof-ver')
        self._boot_ver = DecopString(self.__client, 'boot-ver')
        self._echo = MutableDecopBoolean(self.__client, 'echo')
        self._serial_number = DecopString(self.__client, 'serial-number')
        self._system_type = DecopString(self.__client, 'system-type')
        self._system_model = DecopString(self.__client, 'system-model')
        self._system_label = MutableDecopString(self.__client, 'system-label')
        self._vcs_id = DecopString(self.__client, 'vcs-id')
        self._ssw_vcs_id = DecopString(self.__client, 'ssw-vcs-id')
        self._build_information = BuildInformation(self.__client, 'build-information')
        self._net_conf = Ipconfig(self.__client, 'net-conf')
        self._ul = MutableDecopInteger(self.__client, 'ul')

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
    def emission_button_enabled(self) -> 'MutableDecopBoolean':
        return self._emission_button_enabled

    @property
    def interlock_open(self) -> 'DecopBoolean':
        return self._interlock_open

    @property
    def frontkey_locked(self) -> 'DecopBoolean':
        return self._frontkey_locked

    @property
    def emission(self) -> 'DecopBoolean':
        return self._emission

    @property
    def system_health(self) -> 'DecopInteger':
        return self._system_health

    @property
    def system_health_txt(self) -> 'DecopString':
        return self._system_health_txt

    @property
    def laser1(self) -> 'Laser':
        return self._laser1

    @property
    def laser2(self) -> 'Laser':
        return self._laser2

    @property
    def laser_common(self) -> 'LaserCommon':
        return self._laser_common

    @property
    def uv(self) -> 'UvShgLaser':
        return self._uv

    @property
    def auto_nlo(self) -> 'AutoNloToplevel':
        return self._auto_nlo

    @property
    def cc1(self) -> 'CcBoard':
        return self._cc1

    @property
    def cc2(self) -> 'CcBoard':
        return self._cc2

    @property
    def ampcc1(self) -> 'Cc5000Board':
        return self._ampcc1

    @property
    def ampcc2(self) -> 'Cc5000Board':
        return self._ampcc2

    @property
    def pc1(self) -> 'PcBoard':
        return self._pc1

    @property
    def pc2(self) -> 'PcBoard':
        return self._pc2

    @property
    def pc3(self) -> 'PcBoard':
        return self._pc3

    @property
    def tc1(self) -> 'TcBoard':
        return self._tc1

    @property
    def tc2(self) -> 'TcBoard':
        return self._tc2

    @property
    def mc(self) -> 'McBoard':
        return self._mc

    @property
    def io(self) -> 'IoBoard':
        return self._io

    @property
    def power_supply(self) -> 'PowerSupply':
        return self._power_supply

    @property
    def buzzer(self) -> 'Buzzer':
        return self._buzzer

    @property
    def display(self) -> 'Display':
        return self._display

    @property
    def standby(self) -> 'Standby':
        return self._standby

    @property
    def pdh1(self) -> 'PdhBoard':
        return self._pdh1

    @property
    def falc1(self) -> 'DigifalcBoard':
        return self._falc1

    @property
    def falc2(self) -> 'DigifalcBoard':
        return self._falc2

    @property
    def falc3(self) -> 'DigifalcBoard':
        return self._falc3

    @property
    def falc4(self) -> 'DigifalcBoard':
        return self._falc4

    @property
    def servo_control1(self) -> 'ServoControlBoard':
        return self._servo_control1

    @property
    def servo_control2(self) -> 'ServoControlBoard':
        return self._servo_control2

    @property
    def servo_control3(self) -> 'ServoControlBoard':
        return self._servo_control3

    @property
    def servo_control4(self) -> 'ServoControlBoard':
        return self._servo_control4

    @property
    def mot1(self) -> 'DlMotorBoard':
        return self._mot1

    @property
    def mot2(self) -> 'DlMotorBoard':
        return self._mot2

    @property
    def time(self) -> 'MutableDecopString':
        return self._time

    @property
    def tan(self) -> 'DecopInteger':
        return self._tan

    @property
    def system_messages(self) -> 'SystemMessages':
        return self._system_messages

    @property
    def licenses(self) -> 'Licenses':
        return self._licenses

    @property
    def fw_update(self) -> 'FwUpdate':
        return self._fw_update

    @property
    def system_service_report(self) -> 'ServiceReport':
        return self._system_service_report

    @property
    def uptime(self) -> 'DecopInteger':
        return self._uptime

    @property
    def uptime_txt(self) -> 'DecopString':
        return self._uptime_txt

    @property
    def fw_ver(self) -> 'DecopString':
        return self._fw_ver

    @property
    def ssw_ver(self) -> 'DecopString':
        return self._ssw_ver

    @property
    def decof_ver(self) -> 'DecopString':
        return self._decof_ver

    @property
    def boot_ver(self) -> 'DecopString':
        return self._boot_ver

    @property
    def echo(self) -> 'MutableDecopBoolean':
        return self._echo

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
    def vcs_id(self) -> 'DecopString':
        return self._vcs_id

    @property
    def ssw_vcs_id(self) -> 'DecopString':
        return self._ssw_vcs_id

    @property
    def build_information(self) -> 'BuildInformation':
        return self._build_information

    @property
    def net_conf(self) -> 'Ipconfig':
        return self._net_conf

    @property
    def ul(self) -> 'MutableDecopInteger':
        return self._ul

    def system_connections(self) -> Tuple[str, int]:
        return self.__client.exec('system-connections', input_stream=None, output_type=str, return_type=int)

    def debug_log(self) -> str:
        return self.__client.exec('debug-log', input_stream=None, output_type=str, return_type=None)

    def error_log(self) -> str:
        return self.__client.exec('error-log', input_stream=None, output_type=str, return_type=None)

    def service_log(self) -> str:
        return self.__client.exec('service-log', input_stream=None, output_type=str, return_type=None)

    def service_script(self, input_stream: bytes) -> None:
        assert isinstance(input_stream, bytes), f"expected type 'bytes' for parameter 'input_stream', got '{type(input_stream)}'"
        self.__client.exec('service-script', input_stream=input_stream, output_type=None, return_type=None)

    def service_script_from_usb(self) -> None:
        self.__client.exec('service-script-from-usb', input_stream=None, output_type=None, return_type=None)

    def service_report(self) -> bytes:
        return self.__client.exec('service-report', input_stream=None, output_type=bytes, return_type=None)

    def system_summary(self) -> str:
        return self.__client.exec('system-summary', input_stream=None, output_type=str, return_type=None)

    def change_ul(self, ul: UserLevel, password: Optional[str] = None) -> int:
        assert isinstance(ul, UserLevel), f"expected type 'UserLevel' for parameter 'ul', got '{type(ul)}'"
        assert isinstance(password, str) or password is None, f"expected type 'str' or 'None' for parameter 'password', got '{type(password)}'"
        return self.__client.change_ul(ul, password)

    def change_password(self, password: str) -> None:
        assert isinstance(password, str), f"expected type 'str' for parameter 'password', got '{type(password)}'"
        self.__client.exec('change-password', password, input_stream=None, output_type=None, return_type=None)

    def change_password_service(self, password: str) -> None:
        assert isinstance(password, str), f"expected type 'str' for parameter 'password', got '{type(password)}'"
        self.__client.exec('change-password-service', password, input_stream=None, output_type=None, return_type=None)

