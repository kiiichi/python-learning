import time
import tkinter as tk
from tkinter import ttk
import logging

from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias
from laser_nkt_ctrl import *
from http_instctrl import *
from scpi_instctrl import *
from pyrpl_rpctrl import *

logging.basicConfig(level=logging.INFO)

# 定义常量
THRESHOLD_AUTO_RESET = 0.6
COMMON_UPDATE_INTERVAL = 50
UPDATE_INTERVAL_LASER_STATUS = 200   # 激光器状态更新间隔250ms
UPDATE_INTERVAL_LASER_WL = 100       # 激光器波长更新间隔500ms
UPDATE_INTERVAL_AUTO_RESET = 100      # PID 更新间隔100ms

class ControlCenterGUI(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Control Center GUI")
        
        # 设置窗口自适应布局
        self.columnconfigure(0, weight=1)
        self.rowconfigure(0, weight=1)
        
        # 创建主容器
        self.main_frame = ttk.Frame(self, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.W, tk.E))
        self.main_frame.columnconfigure(0, weight=1)
        
        self.init_variables()
        self.create_regions()  # 分区创建控件
        self.bind_shortcuts()
        
        # 初始化各个部分上次更新的时间
        self.last_pid_update = 0
        self.last_laser_status_update = 0
        self.last_laser_wl_update = 0
        # 启动统一的更新函数
        self.after(COMMON_UPDATE_INTERVAL, self.update_gui)
        
    def init_variables(self) -> None:
        # 设备状态变量
        self.pump_rp_state = tk.StringVar(value='pump_rp_state')
        self.local_rp_state = tk.StringVar(value='local_rp_state')
        self.MC_FL_rp_state = tk.StringVar(value='MC_FL_rp_state')
        self.MC_SL_rp_state = tk.StringVar(value='MC_SL_rp_state')
        
        # PID 测量值显示变量
        self.p1_pid0_ival = tk.StringVar(value='default')
        self.p1_pid1_ival = tk.StringVar(value='default')
        self.p2_pid0_ival = tk.StringVar(value='default')
        self.p2_pid1_ival = tk.StringVar(value='default')
        self.p3_pid0_ival = tk.StringVar(value='default')
        
        # 波长及相关参数
        self.pump_wl = tk.DoubleVar(value=1550)
        self.band1_wl = tk.StringVar(value='center_wl_1')
        self.band2_wl = tk.StringVar(value='center_wl_2')
        self.band_num = tk.StringVar(value='band_num')
        
        # 衰减参数
        self.pump_att = tk.DoubleVar(value=0)
        self.band1_att = tk.DoubleVar(value=0)
        self.band2_att = tk.DoubleVar(value=0)
        
        # 相位参数
        self.pump_degree = tk.DoubleVar(value=0)
        self.band1_degree = tk.DoubleVar(value=0)
        self.band2_degree = tk.DoubleVar(value=0)
        
        # 自动复位检查变量
        self.check_autolock_var = tk.StringVar(value='Manual Reset')

        # 激光器控制变量
        self.laser_nkt_actwl = tk.DoubleVar(value=0)
        self.laser_nkt_setwl = tk.DoubleVar(value=1549.7420)
        self.check_emission_var = tk.StringVar(value='Emission OFF')
        self.laser_nkt_status = tk.StringVar(value='Laser Status')
        
    def create_regions(self) -> None:
        """将界面分为多个区域：设备状态、PID 测量、波长参数、激光器控制、快捷键说明"""
        # 设备状态区
        self.status_frame = ttk.LabelFrame(self.main_frame, text="设备状态", padding="10")
        self.status_frame.grid(row=0, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        ttk.Label(self.status_frame, text="Pump:").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(self.status_frame, textvariable=self.pump_rp_state).grid(row=0, column=1, sticky=tk.W, padx=5)
        ttk.Label(self.status_frame, text="Local:").grid(row=0, column=2, sticky=tk.W)
        ttk.Label(self.status_frame, textvariable=self.local_rp_state).grid(row=0, column=3, sticky=tk.W, padx=5)
        ttk.Label(self.status_frame, text="MC_FL:").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(self.status_frame, textvariable=self.MC_FL_rp_state).grid(row=1, column=1, sticky=tk.W, padx=5)
        ttk.Label(self.status_frame, text="MC_SL:").grid(row=1, column=2, sticky=tk.W)
        ttk.Label(self.status_frame, textvariable=self.MC_SL_rp_state).grid(row=1, column=3, sticky=tk.W, padx=5)
        
        # PID 测量值区
        self.pid_frame = ttk.LabelFrame(self.main_frame, text="PID 测量值", padding="10")
        self.pid_frame.grid(row=1, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        ttk.Label(self.pid_frame, text="Pump PID0:").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(self.pid_frame, textvariable=self.p1_pid0_ival).grid(row=0, column=1, sticky=tk.W, padx=5)
        ttk.Label(self.pid_frame, text="Pump PID1:").grid(row=0, column=2, sticky=tk.W)
        ttk.Label(self.pid_frame, textvariable=self.p1_pid1_ival).grid(row=0, column=3, sticky=tk.W, padx=5)
        ttk.Label(self.pid_frame, text="Local PID0:").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(self.pid_frame, textvariable=self.p2_pid0_ival).grid(row=1, column=1, sticky=tk.W, padx=5)
        ttk.Label(self.pid_frame, text="Local PID1:").grid(row=1, column=2, sticky=tk.W)
        ttk.Label(self.pid_frame, textvariable=self.p2_pid1_ival).grid(row=1, column=3, sticky=tk.W, padx=5)
        ttk.Label(self.pid_frame, text="MC PID:").grid(row=2, column=0, sticky=tk.W)
        ttk.Label(self.pid_frame, textvariable=self.p3_pid0_ival).grid(row=2, column=1, sticky=tk.W, padx=5)
        # 自动复位复选框放在 PID 区
        ttk.Checkbutton(self.pid_frame, text="Auto Reset",
                        variable=self.check_autolock_var,
                        onvalue="Auto Reset", offvalue="Manual Reset").grid(row=2, column=2, sticky=tk.W, padx=5)
        
        # WaveShaper 设置区
        self.wave_frame = ttk.LabelFrame(self.main_frame, text="WaveShaper 波长 (nm on OSA) 及参数设置", padding="10")
        self.wave_frame.grid(row=2, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        # 标题行与 Sideband 信息
        ttk.Label(self.wave_frame, text="Sideband Number:").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(self.wave_frame, textvariable=self.band_num).grid(row=0, column=1, sticky=tk.W, padx=5)
        ttk.Label(self.wave_frame, text="WS 衰减 (dB):").grid(row=0, column=2, sticky=tk.W)
        ttk.Label(self.wave_frame, text="WS 相位 (°):").grid(row=0, column=3, sticky=tk.W)
        # 泵浦波长、衰减、相位设置
        ttk.Label(self.wave_frame, text="Center 波长:").grid(row=1, column=0, sticky=tk.W)
        ttk.Entry(self.wave_frame, textvariable=self.pump_wl, width=9, justify="center")\
             .grid(row=1, column=1, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.pump_att, width=9, justify="center")\
             .grid(row=1, column=2, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.pump_degree, width=9, justify="center")\
             .grid(row=1, column=3, sticky=tk.W, padx=5)
        # Band1 设置
        ttk.Label(self.wave_frame, text="Band1 波长:").grid(row=2, column=0, sticky=tk.W)
        ttk.Label(self.wave_frame, textvariable=self.band1_wl).grid(row=2, column=1, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.band1_att, width=9, justify="center")\
             .grid(row=2, column=2, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.band1_degree, width=9, justify="center")\
             .grid(row=2, column=3, sticky=tk.W, padx=5)
        # Band2 设置
        ttk.Label(self.wave_frame, text="Band2 波长:").grid(row=3, column=0, sticky=tk.W)
        ttk.Label(self.wave_frame, textvariable=self.band2_wl).grid(row=3, column=1, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.band2_att, width=9, justify="center")\
             .grid(row=3, column=2, sticky=tk.W, padx=5)
        ttk.Entry(self.wave_frame, textvariable=self.band2_degree, width=9, justify="center")\
             .grid(row=3, column=3, sticky=tk.W, padx=5)

        # 激光器控制区
        self.laser_frame = ttk.LabelFrame(self.main_frame, text="激光器控制", padding="10")
        self.laser_frame.grid(row=3, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        ttk.Label(self.laser_frame, text="NKT 实际波长 (nm):").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(self.laser_frame, textvariable=self.laser_nkt_actwl, width=9)\
             .grid(row=0, column=1, sticky=tk.W)
        ttk.Label(self.laser_frame, text="设定波长:").grid(row=0, column=2, sticky=tk.W)
        ttk.Entry(self.laser_frame, textvariable=self.laser_nkt_setwl, width=9, justify="center")\
             .grid(row=0, column=3, sticky=tk.W, padx=5)
        # 功率/Emission 控制
        ttk.Checkbutton(self.laser_frame, text="Emission",
                        variable=self.check_emission_var,
                        onvalue="Emission ON", offvalue="Emission OFF")\
             .grid(row=1, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.laser_frame, textvariable=self.laser_nkt_status)\
             .grid(row=1, column=1, sticky=tk.W)

        # 快捷键说明区
        self.shortcut_frame = ttk.LabelFrame(self.main_frame, text="快捷键说明", padding="10")
        self.shortcut_frame.grid(row=4, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        shortcut_texts = [
            "Default rp: ctrl + ( 1 = pump, 2 = local, 3 = MC_FL, 4 = MC_SL, 0 = ALL)",
            "Pump&Local: ctrl+z = ramp, ctrl+r = reset, ctrl+f = lock, ctrl+c = miniramp",
            "MC: ctrl+n = ramp, ctrl+m = reset, ctrl+, = coarselock, ctrl+. = finelock",
            "PSG & WS: ctrl+shift+1~9 或 alt+1~9 = sideband 1-9",
            "NKT: ctrl+enter = set wl, ctrl+(shift)+← = down wl, ctrl+(shift)+→ = up wl",
            "关闭程序: ctrl+q"
        ]
        for i, text in enumerate(shortcut_texts):
            ttk.Label(self.shortcut_frame, text=text)\
                 .grid(row=i, column=0, sticky=tk.W, pady=2)
        
    def bind_shortcuts(self) -> None:
        # 关闭窗口
        self.bind('<Control-q>', lambda e: self.destroy())
        
        # 设备默认设置快捷键
        self.bind('<Control-KeyPress-1>', lambda e: self.setup_device(1))
        self.bind('<Control-KeyPress-2>', lambda e: self.setup_device(2))
        self.bind('<Control-KeyPress-3>', lambda e: self.setup_device(3))
        self.bind('<Control-KeyPress-4>', lambda e: self.setup_device(4))
        self.bind('<Control-KeyPress-0>', lambda e: self.setup_all_devices())
        
        # Pump & Local PID 操作
        self.bind('<Control-KeyPress-r>', lambda e: self.reset_all_pid())
        self.bind('<Control-KeyPress-z>', lambda e: self.start_ramp_all())
        self.bind('<Control-KeyPress-f>', lambda e: self.lock_all())
        self.bind('<Control-KeyPress-c>', lambda e: self.miniramp_local())
        
        # MC PID 操作
        self.bind('<Control-KeyPress-m>', lambda e: p3_pid_reset(0))
        self.bind('<Control-KeyPress-n>', lambda e: self.start_mc_ramp())
        self.bind('<Control-KeyPress-,>', lambda e: self.coarse_lock_mc())
        self.bind('<Control-KeyPress-.>', lambda e: self.fine_lock_mc())
        
        # Sideband 快捷键（Alt 与 Control 修饰键对应不同的 PSG 设置）
        self.bind("<Alt-KeyPress-1>", lambda e: self.set_sideband(1, PSG_freq[0], PSG_power[1]))
        self.bind("<Alt-KeyPress-2>", lambda e: self.set_sideband(2, PSG_freq[0], PSG_power[2]))
        self.bind("<Alt-KeyPress-3>", lambda e: self.set_sideband(3, PSG_freq[0], PSG_power[3]))
        self.bind("<Alt-KeyPress-4>", lambda e: self.set_sideband(4, PSG_freq[0], PSG_power[4]))
        self.bind("<Alt-KeyPress-5>", lambda e: self.set_sideband(5, PSG_freq[0], PSG_power[5]))
        self.bind("<Alt-KeyPress-6>", lambda e: self.set_sideband(6, PSG_freq[0], PSG_power[6]))
        self.bind("<Alt-KeyPress-7>", lambda e: self.set_sideband(7, PSG_freq[0], PSG_power[7]))
        self.bind("<Alt-KeyPress-8>", lambda e: self.set_sideband(8, PSG_freq[0], PSG_power[8]))
        self.bind("<Alt-KeyPress-9>", lambda e: self.set_sideband(9, PSG_freq[0], PSG_power[9]))
        
        self.bind('<Control-KeyPress-!>', lambda e: self.set_sideband(1, PSG_freq[1], PSG_power[1]))
        self.bind('<Control-KeyPress-@>', lambda e: self.set_sideband(2, PSG_freq[2], PSG_power[2]))
        self.bind('<Control-KeyPress-#>', lambda e: self.set_sideband(3, PSG_freq[3], PSG_power[3]))
        self.bind('<Control-KeyPress-$>', lambda e: self.set_sideband(4, PSG_freq[4], PSG_power[4]))
        self.bind('<Control-KeyPress-%>', lambda e: self.set_sideband(5, PSG_freq[5], PSG_power[5]))
        self.bind('<Control-KeyPress-^>', lambda e: self.set_sideband(6, PSG_freq[6], PSG_power[6]))
        self.bind('<Control-KeyPress-&>', lambda e: self.set_sideband(7, PSG_freq[7], PSG_power[7]))
        self.bind('<Control-KeyPress-*>', lambda e: self.set_sideband(8, PSG_freq[8], PSG_power[8]))
        self.bind('<Control-KeyPress-(>', lambda e: self.set_sideband(9, PSG_freq[9], PSG_power[9]))

        # NKT 激光器波长设置及微调
        self.bind('<Control-Return>', lambda e: self.set_laser_nkt_wavelength())
        self.bind('<Control-Left>', lambda e: self.move_laser_nkt_setwl(-0.0001))
        self.bind('<Control-Right>', lambda e: self.move_laser_nkt_setwl(0.0001))
        self.bind('<Control-Shift-Left>', lambda e: self.move_laser_nkt_setwl(-0.001))
        self.bind('<Control-Shift-Right>', lambda e: self.move_laser_nkt_setwl(0.001))
        
    def update_gui(self) -> None:
        """统一更新界面，依据各部分的不同更新时间间隔执行各自更新操作。"""
        now = time.time()
        if now - self.last_pid_update >= UPDATE_INTERVAL_AUTO_RESET / 1000.0:
            self.update_pid_values()
            self.last_pid_update = now
        if now - self.last_laser_status_update >= UPDATE_INTERVAL_LASER_STATUS / 1000.0:
            self.update_laser_status()
            self.last_laser_status_update = now
        if now - self.last_laser_wl_update >= UPDATE_INTERVAL_LASER_WL / 1000.0:
            self.update_laser_wavelength()
            self.last_laser_wl_update = now
        
        # 每 COMMON_UPDATE_INTERVAL 毫秒检查一次
        self.after(COMMON_UPDATE_INTERVAL, self.update_gui)

    def update_laser_status(self) -> None:
        """更新 NKT 激光器状态显示，仅在状态变化时调用开/关函数。"""
        try:
            current_emission = self.check_emission_var.get()
            # 如果不存在 _last_emission 属性，则初始化它
            if not hasattr(self, '_last_emission'):
                self._last_emission = None

            # 只有当状态发生变化时才调用相应的函数
            if current_emission != self._last_emission:
                if current_emission == 'Emission ON':
                    nkt_turn_on()
                else:
                    nkt_turn_off()
                self._last_emission = current_emission

            # 始终更新状态显示
            self.laser_nkt_status.set(nkt_read_status())
        except Exception as e:
            logging.error("Error updating NKT laser status: %s", e)


    def update_laser_wavelength(self) -> None:
        """更新 NKT 激光器波长显示。"""
        try:
            self.laser_nkt_actwl.set(nkt_read_wavelength())
        except Exception as e:
            logging.error("Error updating NKT laser wavelength: %s", e)

    def update_pid_values(self) -> None:
        """获取 PID 值并更新界面，同时检查是否需要自动复位。"""
        try:
            # 读取各 PID 当前的值
            p1_val0 = p1_pid0.ival
            p1_val1 = p1_pid1.ival
            p2_val0 = p2_pid0.ival
            p2_val1 = p2_pid1.ival
            p3_val0 = p3_pid0.ival
            
            # 更新显示
            self.p1_pid0_ival.set(f"{p1_val0:.2f}")
            self.p1_pid1_ival.set(f"{p1_val1:.2f}")
            self.p2_pid0_ival.set(f"{p2_val0:.2f}")
            self.p2_pid1_ival.set(f"{p2_val1:.2f}")
            self.p3_pid0_ival.set(f"{p3_val0:.2f}")
            
            # 自动复位判断
            if self.check_autolock_var.get() == 'Auto Reset':
                self.check_and_reset(p1_val0, p1_pid_reset, 0)
                self.check_and_reset(p1_val1, p1_pid_reset, 1)
                self.check_and_reset(p2_val0, p2_pid_reset, 0)
                self.check_and_reset(p2_val1, p2_pid_reset, 1)
        except Exception as e:
            logging.error("Error updating PID values: %s", e)
            
    def check_and_reset(self, pid_value: float, reset_func, channel: int) -> None:
        """当 PID 值超过设定阈值时进行复位。"""
        if abs(pid_value) > THRESHOLD_AUTO_RESET:
            try:
                reset_func(channel)
                logging.info("Reset PID channel %d with value %.2f", channel, pid_value)
            except Exception as e:
                logging.error("Failed to reset PID channel %d: %s", channel, e)

    def ws_toptica_set(self, n: int) -> None:
        """根据 sideband 参数 n 设置波长，并更新界面显示。"""
        try:
            center_wl_1, center_wl_2 = ws_dualband_setup(
                self.pump_wl.get(), FSR * n, 40,
                attenuation=[self.band1_att.get(), self.pump_att.get(), self.band2_att.get()],
                phase=[self.band1_degree.get(), self.pump_degree.get(), self.band2_degree.get()]
            )
            ctrl_toptica1(center_wl_2 + toptica1_wl_bias)
            ctrl_toptica2(center_wl_1 + toptica2_wl_bias)
            self.band1_wl.set(f"{center_wl_1:.5f} nm")
            self.band2_wl.set(f"{center_wl_2:.5f} nm")
        except Exception as e:
            logging.error("Error in ws_toptica_set: %s", e)
            
    def setup_device(self, device_number: int) -> None:
        """根据 device_number 设置对应设备的默认状态。"""
        try:
            if device_number == 1:
                p1_setup()
                self.pump_rp_state.set('Pump&P_ref Default')
            elif device_number == 2:
                p2_setup()
                self.local_rp_state.set('Local Default')
            elif device_number == 3:
                p3_setup()
                self.MC_FL_rp_state.set('MC_FL Default')
            elif device_number == 4:
                p4_setup()
                self.MC_SL_rp_state.set('MC_SL Default')
        except Exception as e:
            logging.error("Error setting up device %d: %s", device_number, e)
            
    def setup_all_devices(self) -> None:
        """设置所有设备为默认状态。"""
        self.setup_device(1)
        self.setup_device(2)
        self.setup_device(3)
        self.setup_device(4)
        self.pump_rp_state.set('Pump&P_ref Default')
        self.local_rp_state.set('Local Default')
        self.MC_FL_rp_state.set('MC_FL Default')
        self.MC_SL_rp_state.set('MC_SL Default')
        
    def reset_all_pid(self) -> None:
        """复位 Pump 与 Local 的所有 PID 通道。"""
        try:
            p1_pid_reset(0)
            p1_pid_reset(1)
            p2_pid_reset(0)
            p2_pid_reset(1)
        except Exception as e:
            logging.error("Error resetting all PID: %s", e)
            
    def start_ramp_all(self) -> None:
        """开始 Pump 与 Local 的 ramping 操作。"""
        try:
            p1_pid_paused(0)
            p1_pid_paused(1)
            p2_pid_paused(0)
            p2_pid_paused(1)
            p1_pid_reset(0)
            p1_pid_reset(1)
            p2_pid_reset(0)
            p2_pid_reset(1)
            p1_ramp_on(0)
            p1_ramp_on(1)
            p2_ramp_on(0)
            p2_ramp_on(1)
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local Ramping')
        except Exception as e:
            logging.error("Error starting ramp: %s", e)
            
    def lock_all(self) -> None:
        """关闭 ramping 并解锁 Pump 与 Local 的 PID。"""
        try:
            p1_ramp_off(0)
            p1_ramp_off(1)
            p2_ramp_off(0)
            p2_ramp_off(1)
            p1_pid_unpaused(0)
            p1_pid_unpaused(1)
            p2_pid_unpaused(0)
            p2_pid_unpaused(1)
            self.pump_rp_state.set('Pump&P_ref Locked')
            self.local_rp_state.set('Local Locked')
        except Exception as e:
            logging.error("Error locking PID: %s", e)
            
    def miniramp_local(self) -> None:
        """对 Local PID 进行 miniramp 操作。"""
        try:
            p1_pid_paused(0)
            p1_pid_paused(1)
            p2_pid_paused(0)
            p2_pid_paused(1)
            p1_pid_reset(0)
            p1_pid_reset(1)
            p2_pid_reset(0)
            p2_pid_reset(1)
            p1_ramp_on(0)
            p1_ramp_on(1)
            p2_miniramp_on(0)
            p2_ramp_off(1)
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local1 Miniramping')
        except Exception as e:
            logging.error("Error in miniramp for local: %s", e)
            
    def start_mc_ramp(self) -> None:
        """开始 MC PID 的 ramping 操作。"""
        try:
            p3_pid_paused(0)
            p3_pid_reset(0)
            p3_ramp_on(0)
            p3_ramp_off(1)
            self.MC_FL_rp_state.set('MC Ramping')
        except Exception as e:
            logging.error("Error starting MC ramp: %s", e)
            
    def coarse_lock_mc(self) -> None:
        """MC PID 进行 coarse locking。"""
        try:
            p3_ramp_off(0)
            slow_ramp('on')
            p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Coarse Locking')
        except Exception as e:
            logging.error("Error in MC coarse lock: %s", e)
            
    def fine_lock_mc(self) -> None:
        """MC PID 进行 fine locking。"""
        try:
            slow_ramp('off')
            p3_pid_reset(0)
            p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Fine Locking')
        except Exception as e:
            logging.error("Error in MC fine lock: %s", e)
            
    def set_sideband(self, sideband: int, psg_frequency, psg_power) -> None:
        """设置 PSG 与 WS 的 sideband，并更新显示。"""
        try:
            ctrl_psg(psg_frequency, psg_power)
            self.ws_toptica_set(sideband)
            self.band_num.set(f'Side Band {sideband}')
        except Exception as e:
            logging.error("Error setting sideband %d: %s", sideband, e)

    def set_laser_nkt_wavelength(self) -> None:
        """设置 NKT 激光器波长。"""
        try:
            nkt_write_wl(self.laser_nkt_setwl.get())
        except Exception as e:
            logging.error("Error setting NKT laser wavelength: %s", e)

    def move_laser_nkt_setwl(self, value: float = 0.001) -> None:
        """调整 NKT 激光器的设定波长，并应用新设置。"""
        self.laser_nkt_setwl.set(self.laser_nkt_setwl.get() + value)
        self.set_laser_nkt_wavelength()


if __name__ == "__main__":
    app = ControlCenterGUI()
    app.mainloop()
