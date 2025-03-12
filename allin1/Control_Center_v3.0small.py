import time
import tkinter as tk
from tkinter import ttk
import logging
import threading
import queue

from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias, PORTNAME_NKT
from Ctrl_LaserNkt import *
from Ctrl_HttpInstr import *
from Ctrl_ScpiInstr import *
from Ctrl_PyrplInstr import *

logging.basicConfig(level=logging.INFO)

# 定义常量
THRESHOLD_AUTO_RESET = 0.6

COMMON_UPDATE_INTERVAL = 50         # 最小更新间隔单位 ms
UPDATE_INTERVAL_LASER_STATUS = 200   # 激光器状态更新间隔
UPDATE_INTERVAL_AUTO_RESET = 100      # PID 更新间隔
UPDATE_INTERVAL_OSC_VAVG = 2000     # 示波器 VAVG 更新间隔

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
        
        # 为NKT通信创建队列和线程
        self.nkt_emission_queue = queue.Queue()
        self.nkt_wl_queue = queue.Queue()
        self.nkt_thread_running = True
        self.nkt_thread = threading.Thread(target=self.nkt_worker_thread, daemon=True)
        self.nkt_thread.start()

        # 为示波器通信创建队列和线程
        self.osc_queue = queue.Queue()
        self.avag_queue = queue.Queue()
        self.osc_thread_running = True
        self.osc_thread = threading.Thread(target=self.osc_worker_thread, daemon=True)
        self.osc_thread.start()
        
        self.init_variables()
        self.create_regions()  # 分区创建控件
        self.bind_shortcuts()
        
        # # 初始化
        # self.last_pid_update = 0
        # self.last_laser_status_update = 0
        # self.last_laser_wl_update = 0
        # self.last_osc_vavg_update = 0
        # self.last_lockvavg_update = 0

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
        self.last_pid_update = 0
        
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
        self.laser_nkt_actwl = tk.StringVar(value='default')
        self.laser_nkt_setwl = tk.DoubleVar(value=1549.7420)
        self.check_emission_var = tk.StringVar(value='Emission OFF')
        self.laser_nkt_status = tk.StringVar(value='Laser Status')
        self.last_laser_status_update = 0
        self.last_laser_wl_update = 0

        # 示波器控制变量
        self.oscmeas_var = tk.StringVar(value='OFF')
        self.osc_vavg1 = tk.DoubleVar(value=0)
        self.check_lockvavg_var = tk.StringVar(value='Unlock VAVG')
        self.setpoint_vavg1 = tk.DoubleVar(value=0)
        self.lockvavg_kp = tk.DoubleVar(value=0.1)
        self.lockvavg_ki = tk.DoubleVar(value=0.1)
        self.lockvavg_kd = tk.DoubleVar(value=0.1)
        self.lockvavg_ctrlsignal = tk.StringVar(value="default")
        self.lockvavg_integral = 0
        self.lockvavg_last_error = 0
        self.last_osc_vavg_update = 0
        self.last_lockvavg_update = 0
        
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
        self.laser_nkt_setwl.trace_add("write", lambda *args: self.laser_nkt_setwl.set(f"{self.laser_nkt_setwl.get():.4f}"))
        ttk.Checkbutton(self.laser_frame, text="Emission",
                        variable=self.check_emission_var,
                        onvalue="Emission ON", offvalue="Emission OFF")\
             .grid(row=1, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.laser_frame, textvariable=self.laser_nkt_status)\
             .grid(row=1, column=1, sticky=tk.W)
        ttk.Label(self.laser_frame, text="波长移动 (pm):").grid(row=1, column=2, sticky=tk.W)
        ttk.Label(self.laser_frame, textvariable=self.lockvavg_ctrlsignal, width=9).grid(row=1, column=3, sticky=tk.E)
        
        # 示波器控制区
        self.osc_frame = ttk.LabelFrame(self.main_frame, text="示波器控制", padding="10")
        self.osc_frame.grid(row=4, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        ttk.Checkbutton(self.osc_frame, text="测量值读取",
        variable=self.oscmeas_var,
        onvalue="ON", offvalue="OFF").grid(row=0, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.osc_frame, text="CH1 VAVG (mV):").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(self.osc_frame, textvariable=self.osc_vavg1, width=9).grid(row=1, column=1, sticky=tk.W)
        ttk.Checkbutton(self.osc_frame, text="锁定 VAVG",
                        variable=self.check_lockvavg_var,
                        onvalue="Lock VAVG", offvalue="Unlock VAVG").grid(row=2, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.osc_frame, text="Setpoint:").grid(row=1, column=2, sticky=tk.W)
        ttk.Label(self.osc_frame, textvariable=self.setpoint_vavg1, width=9).grid(row=1, column=3, sticky=tk.W)
        ttk.Label(self.osc_frame, text="Kp").grid(row=2, column=1)
        ttk.Label(self.osc_frame, text="Ki").grid(row=2, column=2)
        ttk.Label(self.osc_frame, text="Kd").grid(row=2, column=3)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_kp, width=5, justify="center")\
             .grid(row=3, column=1, sticky=tk.EW, padx=5)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_ki, width=5, justify="center")\
             .grid(row=3, column=2, sticky=tk.EW, padx=5)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_kd, width=5, justify="center")\
             .grid(row=3, column=3, sticky=tk.EW, padx=5)


        # 快捷键说明区
        self.shortcut_frame = ttk.LabelFrame(self.main_frame, text="快捷键说明", padding="10")
        self.shortcut_frame.grid(row=5, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
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
    
    def nkt_worker_thread(self):
        """NKT 激光器通信工作线程，在后台持续运行获取激光器数据"""
        while self.nkt_thread_running:
            try:
                now = time.time()
                # 获取激光器数据
                status = LaserNkt.read_status()
                act_wl = LaserNkt.read_wavelength()
                # 将结果放入队列
                self.nkt_emission_queue.put(status)
                self.nkt_wl_queue.put(act_wl)
                if not self.avag_queue.empty():
                    ctrlsignal = self.avag_queue.get()
                    self.lockvavg_ctrlsignal.set(f"{ctrlsignal*1000:.6f}")
                    self.move_laser_nkt_setwl(ctrlsignal)
                # 线程休眠一段时间
                time.sleep(UPDATE_INTERVAL_LASER_STATUS / 1000.0)

            except Exception as e:
                logging.error("Error in NKT laser wavelength worker thread: %s", e)
                # 出错后稍微等待一下再重试
                time.sleep(1)

    def osc_worker_thread(self):
        """示波器通信工作线程，在后台持续运行获取示波器数据"""
        while self.osc_thread_running and self.oscmeas_var.get() == 'ON':
            try:
                # 获取示波器数据
                vavg_value = ScpiInstr.query_osc_vavg(1)
                # 将结果放入队列
                self.osc_queue.put(vavg_value)
                # 线程休眠一段时间
                time.sleep(UPDATE_INTERVAL_OSC_VAVG / 1000.0)
            except Exception as e:
                logging.error("Error in oscilloscope worker thread: %s", e)
                # 出错后稍微等待一下再重试
                time.sleep(1)
        
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
        self.bind('<Control-KeyPress-m>', lambda e: PyrplInstr.p3_pid_reset(0))
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
            self.update_pid_rp()
            self.last_pid_update = now
        if now - self.last_laser_status_update >= UPDATE_INTERVAL_LASER_STATUS / 1000.0:
            self.emission_laser_nkt()
            self.update_laser_status() # 多线程获取激光器数据
            self.last_laser_status_update = now
        if now - self.last_osc_vavg_update >= UPDATE_INTERVAL_OSC_VAVG / 1000.0:
            self.update_osc_vavg() # 多线程获取示波器数据
            self.last_osc_vavg_update = now
        if now - self.last_lockvavg_update >= UPDATE_INTERVAL_OSC_VAVG / 1000.0:
            self.update_pid_vavg()
            self.last_lockvavg_update = now
        
        # 每 COMMON_UPDATE_INTERVAL 毫秒检查一次
        self.after(COMMON_UPDATE_INTERVAL, self.update_gui)

    def update_pid_vavg(self) -> None: 
        try:
            current_lockvavg = self.check_lockvavg_var.get()
            if not hasattr(self, '_last_lockvavg'):
                self._last_lockvavg = None
            if current_lockvavg != self._last_lockvavg:
                if current_lockvavg == 'Lock VAVG':
                    self.lockvavg_integral = 0
                    self.lockvavg_last_error = 0
                    self.setpoint_vavg1.set(self.osc_vavg1.get())
                self._last_lockvavg = current_lockvavg
            if current_lockvavg == 'Lock VAVG':
                error = self.setpoint_vavg1.get() - self.osc_vavg1.get()
                self.lockvavg_integral += error * UPDATE_INTERVAL_OSC_VAVG / 1000.0
                derivative = (error - self.lockvavg_last_error) / (UPDATE_INTERVAL_OSC_VAVG / 1000.0)
                output = (self.lockvavg_kp.get() * error + self.lockvavg_ki.get() * self.lockvavg_integral + self.lockvavg_kp.get() * derivative)
                max_output = 1
                output = max(min(output, max_output), -max_output) / 1000.0
                print(output)
                self.avag_queue.put(output)
                self.lockvavg_last_error = error
                logging.info("Locking VAVG: error=%.2f, integral=%.2f, derivative=%.2f, output=%.2f", error, self.lockvavg_integral, derivative, output)
        except Exception as e:
            logging.error("Error updating PID VAVG: %s", e)

    def update_osc_vavg(self) -> None:
        """更新示波器 Channel 1 平均电压值，现在从队列获取多线程获取的数据。"""
        try:
            # 检查队列中是否有数据
            if not self.osc_queue.empty():
                # 从队列获取最新的示波器数据
                vavg_value = self.osc_queue.get()
                # 更新界面显示
                self.osc_vavg1.set(vavg_value)
                # print(vavg_value)
        except Exception as e:
            logging.error("Error updating oscilloscope vavg: %s", e) 

    def emission_laser_nkt(self) -> None:
        """更新 NKT 激光器激发状态"""
        try:
            current_emission = self.check_emission_var.get()
            # 如果不存在 _last_emission 属性，则初始化它
            if not hasattr(self, '_last_emission'):
                self._last_emission = None

            # 只有当状态发生变化时才调用相应的函数
            if current_emission != self._last_emission:
                if current_emission == 'Emission ON':
                    LaserNkt.turn_on()
                else:
                    LaserNkt.turn_off()
                self._last_emission = current_emission

            # 始终更新状态显示
            # self.laser_nkt_status.set(LaserNkt.read_status())
        except Exception as e:
            logging.error("Error updating NKT laser status: %s", e)


    def update_laser_status(self) -> None:
        """更新 NKT 激光器信息显示。"""
        try:
            # 检查队列中是否有数据
            if not self.nkt_emission_queue.empty():
                # 从队列获取最新的激光器状态数据
                status = self.nkt_emission_queue.get()
                # 更新界面显示
                self.laser_nkt_status.set(status)
            if not self.nkt_wl_queue.empty():
                act_wl = self.nkt_wl_queue.get()
                self.laser_nkt_actwl.set(f"{act_wl:.4f}")
        except Exception as e:
            logging.error("Error updating NKT laser wavelength: %s", e)

    def update_pid_rp(self) -> None:
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
                self.check_and_reset(p1_val0, PyrplInstr.p1_pid_reset, 0)
                self.check_and_reset(p1_val1, PyrplInstr.p1_pid_reset, 1)
                self.check_and_reset(p2_val0, PyrplInstr.p2_pid_reset, 0)
                self.check_and_reset(p2_val1, PyrplInstr.p2_pid_reset, 1)
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
            center_wl_1, center_wl_2 = HttpInstr.ws_dualband_setup(
                self.pump_wl.get(), FSR * n, 40,
                attenuation=[self.band1_att.get(), self.pump_att.get(), self.band2_att.get()],
                phase=[self.band1_degree.get(), self.pump_degree.get(), self.band2_degree.get()]
            )
            ScpiInstr.ctrl_toptica1(center_wl_2 + toptica1_wl_bias)
            ScpiInstr.ctrl_toptica2(center_wl_1 + toptica2_wl_bias)
            self.band1_wl.set(f"{center_wl_1:.5f} nm")
            self.band2_wl.set(f"{center_wl_2:.5f} nm")
        except Exception as e:
            logging.error("Error in ws_toptica_set: %s", e)

    def setup_device(self, device_number: int) -> None:
        """根据 device_number 设置对应设备的默认状态。"""
        try:
            if device_number == 1:
                PyrplInstr.p1_setup()
                self.pump_rp_state.set('Pump&P_ref Default')
            elif device_number == 2:
                PyrplInstr.p2_setup()
                self.local_rp_state.set('Local Default')
            elif device_number == 3:
                PyrplInstr.p3_setup()
                self.MC_FL_rp_state.set('MC_FL Default')
            elif device_number == 4:
                PyrplInstr.p4_setup()
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
            PyrplInstr.p1_pid_reset(0)
            PyrplInstr.p1_pid_reset(1)
            PyrplInstr.p2_pid_reset(0)
            PyrplInstr.p2_pid_reset(1)
        except Exception as e:
            logging.error("Error resetting all PID: %s", e)

    def start_ramp_all(self) -> None:
        """开始 Pump 与 Local 的 ramping 操作。"""
        try:
            PyrplInstr.p1_pid_paused(0)
            PyrplInstr.p1_pid_paused(1)
            PyrplInstr.p2_pid_paused(0)
            PyrplInstr.p2_pid_paused(1)
            PyrplInstr.p1_pid_reset(0)
            PyrplInstr.p1_pid_reset(1)
            PyrplInstr.p2_pid_reset(0)
            PyrplInstr.p2_pid_reset(1)
            PyrplInstr.p1_ramp_on(0)
            PyrplInstr.p1_ramp_on(1)
            PyrplInstr.p2_ramp_on(0)
            PyrplInstr.p2_ramp_on(1)
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local Ramping')
        except Exception as e:
            logging.error("Error starting ramp: %s", e)
            
    def lock_all(self) -> None:
        """关闭 ramping 并解锁 Pump 与 Local 的 PID。"""
        try:
            PyrplInstr.p1_ramp_off(0)
            PyrplInstr.p1_ramp_off(1)
            PyrplInstr.p2_ramp_off(0)
            PyrplInstr.p2_ramp_off(1)
            PyrplInstr.p1_pid_unpaused(0)
            PyrplInstr.p1_pid_unpaused(1)
            PyrplInstr.p2_pid_unpaused(0)
            PyrplInstr.p2_pid_unpaused(1)
            self.pump_rp_state.set('Pump&P_ref Locked')
            self.local_rp_state.set('Local Locked')
        except Exception as e:
            logging.error("Error locking PID: %s", e)

    def miniramp_local(self) -> None:
        """对 Local PID 进行 miniramp 操作。"""
        try:
            PyrplInstr.p1_pid_paused(0)
            PyrplInstr.p1_pid_paused(1)
            PyrplInstr.p2_pid_paused(0)
            PyrplInstr.p2_pid_paused(1)
            PyrplInstr.p1_pid_reset(0)
            PyrplInstr.p1_pid_reset(1)
            PyrplInstr.p2_pid_reset(0)
            PyrplInstr.p2_pid_reset(1)
            PyrplInstr.p1_ramp_on(0)
            PyrplInstr.p1_ramp_on(1)
            PyrplInstr.p2_miniramp_on(0)
            PyrplInstr.p2_ramp_off(1)
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local1 Miniramping')
        except Exception as e:
            logging.error("Error in miniramp for local: %s", e)
            
    def start_mc_ramp(self) -> None:
        """开始 MC PID 的 ramping 操作。"""
        try:
            PyrplInstr.p3_pid_paused(0)
            PyrplInstr.p3_pid_reset(0)
            PyrplInstr.p3_ramp_on(0)
            PyrplInstr.p3_ramp_off(1)
            self.MC_FL_rp_state.set('MC Ramping')
        except Exception as e:
            logging.error("Error starting MC ramp: %s", e)
            
    def coarse_lock_mc(self) -> None:
        """MC PID 进行 coarse locking。"""
        try:
            PyrplInstr.p3_ramp_off(0)
            PyrplInstr.slow_ramp('on')
            PyrplInstr.p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Coarse Locking')
        except Exception as e:
            logging.error("Error in MC coarse lock: %s", e)
            
    def fine_lock_mc(self) -> None:
        """MC PID 进行 fine locking。"""
        try:
            PyrplInstr.slow_ramp('off')
            PyrplInstr.p3_pid_reset(0)
            PyrplInstr.p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Fine Locking')
        except Exception as e:
            logging.error("Error in MC fine lock: %s", e)
            
    def set_sideband(self, sideband: int, psg_frequency, psg_power) -> None:
        """设置 PSG 与 WS 的 sideband，并更新显示。"""
        try:
            ScpiInstr.ctrl_psg(psg_frequency, psg_power)
            self.ws_toptica_set(sideband)
            self.band_num.set(f'Side Band {sideband}')
        except Exception as e:
            logging.error("Error setting sideband %d: %s", sideband, e)

    def set_laser_nkt_wavelength(self) -> None:
        """设置 NKT 激光器波长。"""
        try:
            LaserNkt.write_wl(self.laser_nkt_setwl.get())
        except Exception as e:
            logging.error("Error setting NKT laser wavelength: %s", e)

    def move_laser_nkt_setwl(self, value: float = 0.001) -> None:
        """调整 NKT 激光器的设定波长，并应用新设置。"""
        self.laser_nkt_setwl.set(self.laser_nkt_setwl.get() + value)
        self.set_laser_nkt_wavelength()
        
    def destroy(self):
        """重写 destroy 方法，确保正确关闭工作线程"""
        # 停止激光器工作线程
        self.nkt_thread_running = False
        if hasattr(self, 'nkt_thread') and self.nkt_thread.is_alive():
            self.nkt_thread.join(1.0)  # 等待线程最多1秒钟完成
        # 停止示波器工作线程
        self.osc_thread_running = False
        if hasattr(self, 'osc_thread') and self.osc_thread.is_alive():
            self.osc_thread.join(1.0)  # 等待线程最多1秒钟完成
        # 调用父类的 destroy 方法
        super().destroy()


if __name__ == "__main__":
    app = ControlCenterGUI()
    app.mainloop()