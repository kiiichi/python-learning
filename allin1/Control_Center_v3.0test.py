import time
import tkinter as tk
from tkinter import ttk
import logging
import threading
import queue
from concurrent.futures import ThreadPoolExecutor
from functools import partial

from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias
from Ctrl_LaserNkt import *
from Ctrl_HttpInstr import *
from Ctrl_ScpiInstr import *
from Ctrl_PyrplInstr import *

logging.basicConfig(level=logging.INFO, 
                    format='%(asctime)s - %(threadName)s - %(levelname)s - %(message)s')

# 定义常量
THRESHOLD_AUTO_RESET = 0.6

COMMON_UPDATE_INTERVAL = 50         # 最小更新间隔单位 ms

UPDATE_INTERVAL_LASER_STATUS = 200   # 激光器状态更新间隔
UPDATE_INTERVAL_LASER_WL = 200       # 激光器波长更新间隔
UPDATE_INTERVAL_AUTO_RESET = 100      # PID 更新间隔

UPDATE_INTERVAL_OSC_VAVG = 2000     # 示波器 VAVG 更新间隔

# 线程池大小
MAX_WORKERS = 5

class ThreadSafeObject:
    """线程安全对象的基类，提供基本的锁机制"""
    def __init__(self):
        self._lock = threading.RLock()
    
    def with_lock(self, func, *args, **kwargs):
        """使用锁执行函数"""
        with self._lock:
            return func(*args, **kwargs)

class DeviceManager(ThreadSafeObject):
    """设备管理器，处理所有硬件通信，确保线程安全"""
    def __init__(self, result_queue):
        super().__init__()
        self.result_queue = result_queue
        self.executor = ThreadPoolExecutor(max_workers=MAX_WORKERS)
        self.running = True
        
    def shutdown(self):
        """关闭线程池"""
        self.running = False
        self.executor.shutdown(wait=False)
    
    def async_execute(self, task_id, func, *args, **kwargs):
        """异步执行任务并将结果放入队列"""
        if not self.running:
            return
            
        future = self.executor.submit(self._safe_execute, func, *args, **kwargs)
        future.add_done_callback(
            lambda f: self.result_queue.put((task_id, f.result())) if not f.exception() else 
            self.result_queue.put((task_id, None, f.exception()))
        )
        return future
    
    def _safe_execute(self, func, *args, **kwargs):
        """安全执行函数，确保异常被捕获"""
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logging.error(f"Error executing {func.__name__}: {e}")
            raise

    # 特定设备功能封装
    def get_pid_values(self):
        """获取所有PID值"""
        return {
            'p1_pid0': p1_pid0.ival,
            'p1_pid1': p1_pid1.ival,
            'p2_pid0': p2_pid0.ival,
            'p2_pid1': p2_pid1.ival,
            'p3_pid0': p3_pid0.ival
        }
    
    def get_laser_wavelength(self):
        """获取激光器波长"""
        return LaserNkt.read_wavelength()
    
    def get_laser_status(self):
        """获取激光器状态"""
        return LaserNkt.read_status()
    
    def set_laser_wavelength(self, wavelength):
        """设置激光器波长"""
        return LaserNkt.write_wl(wavelength)
    
    def get_osc_vavg(self, channel):
        """获取示波器平均电压"""
        return ScpiInstr.query_osc_vavg(channel)
    
    def set_emission(self, on=True):
        """设置激光器发射状态"""
        if on:
            return LaserNkt.turn_on()
        else:
            return LaserNkt.turn_off()
    
    def setup_waveshaper(self, pump_wl, fsr_n, bandwidth, attenuation, phase):
        """设置WaveShaper"""
        return HttpInstr.ws_dualband_setup(pump_wl, fsr_n, bandwidth, attenuation=attenuation, phase=phase)
    
    def setup_psg(self, frequency, power):
        """设置PSG"""
        return ScpiInstr.ctrl_psg(frequency, power)
    
    def set_toptica(self, wl1, wl2):
        """设置Toptica"""
        ScpiInstr.ctrl_toptica1(wl1)
        ScpiInstr.ctrl_toptica2(wl2)

# 日志处理
class TextHandler(logging.Handler):
    def __init__(self, text_widget):
        super().__init__()
        self.text_widget = text_widget
        
    def emit(self, record):
        msg = self.format(record)
        def append():
            self.text_widget.configure(state='normal')
            if record.levelno >= logging.ERROR:
                self.text_widget.insert(tk.END, msg + '\n', 'error')
            elif record.levelno >= logging.WARNING:
                self.text_widget.insert(tk.END, msg + '\n', 'warning')
            else:
                self.text_widget.insert(tk.END, msg + '\n', 'info')
            self.text_widget.configure(state='disabled')
            self.text_widget.yview(tk.END)
        self.text_widget.after(0, append)

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
        
        # 创建通信队列和设备管理器
        self.result_queue = queue.Queue()
        self.device_manager = DeviceManager(self.result_queue)
        
        # 初始化定期任务状态
        self.update_tasks = {}
        self.update_tasks_lock = threading.Lock()
        
        self.init_variables()
        self.create_regions()  # 分区创建控件
        self.bind_shortcuts()
        
        # 启动队列处理和UI更新
        self.after(COMMON_UPDATE_INTERVAL, self.process_queue)
        self.start_periodic_updates()

        # 添加日志处理
        text_handler = TextHandler(self.log_text)
        text_handler.setFormatter(logging.Formatter('%(asctime)s - %(threadName)s - %(levelname)s - %(message)s'))
        logging.getLogger().addHandler(text_handler)
        
        # 窗口关闭时清理资源
        self.protocol("WM_DELETE_WINDOW", self.on_closing)
        
    def on_closing(self):
        """窗口关闭时，停止所有线程"""
        logging.info("Shutting down application...")
        # 停止所有更新任务
        with self.update_tasks_lock:
            for task_id in self.update_tasks:
                self.update_tasks[task_id] = False
        # 关闭设备管理器
        self.device_manager.shutdown()
        self.destroy()
        
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
        self.laser_nkt_actwl = tk.StringVar(value='default')
        self.laser_nkt_setwl = tk.DoubleVar(value=1549.7420)
        self.check_emission_var = tk.StringVar(value='Emission OFF')
        self.laser_nkt_status = tk.StringVar(value='Laser Status')
        
        # 示波器控制变量
        self.osc_vavg1 = tk.DoubleVar(value=0)
        self.check_lockvavg_var = tk.StringVar(value='Unlock VAVG')
        self.setpoint_vavg1 = tk.DoubleVar(value=0)
        self.lockvavg_kp = tk.DoubleVar(value=0.1)
        self.lockvavg_ki = tk.DoubleVar(value=0.1)
        self.lockvavg_kd = tk.DoubleVar(value=0.1)
        self.lockvavg_integral = 0
        self.lockvavg_last_error = 0
        
        # 添加线程安全的状态跟踪
        self._last_emission = None
        self._last_lockvavg = None
        
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
        # 功率/Emission 控制
        ttk.Checkbutton(self.laser_frame, text="Emission",
                        variable=self.check_emission_var,
                        onvalue="Emission ON", offvalue="Emission OFF",
                        command=self.on_emission_changed)\
             .grid(row=1, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.laser_frame, textvariable=self.laser_nkt_status)\
             .grid(row=1, column=1, sticky=tk.W)
        
        # 示波器控制区
        self.osc_frame = ttk.LabelFrame(self.main_frame, text="示波器控制", padding="10")
        self.osc_frame.grid(row=4, column=0, padx=5, pady=5, sticky=(tk.W, tk.E))
        ttk.Label(self.osc_frame, text="CH1 VAVG (mV):").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(self.osc_frame, textvariable=self.osc_vavg1, width=9).grid(row=0, column=1, sticky=tk.W)
        ttk.Checkbutton(self.osc_frame, text="锁定 VAVG",
                        variable=self.check_lockvavg_var,
                        onvalue="Lock VAVG", offvalue="Unlock VAVG",
                        command=self.on_lockvavg_changed).grid(row=1, column=0, sticky=tk.W, padx=5)
        ttk.Label(self.osc_frame, text="Setpoint:").grid(row=0, column=2, sticky=tk.W)
        ttk.Label(self.osc_frame, textvariable=self.setpoint_vavg1, width=9).grid(row=0, column=3, sticky=tk.W)
        ttk.Label(self.osc_frame, text="Kp").grid(row=1, column=1)
        ttk.Label(self.osc_frame, text="Ki").grid(row=1, column=2)
        ttk.Label(self.osc_frame, text="Kd").grid(row=1, column=3)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_kp, width=5, justify="center")\
             .grid(row=2, column=1, sticky=tk.EW, padx=5)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_ki, width=5, justify="center")\
             .grid(row=2, column=2, sticky=tk.EW, padx=5)
        ttk.Entry(self.osc_frame, textvariable=self.lockvavg_kd, width=5, justify="center")\
             .grid(row=2, column=3, sticky=tk.EW, padx=5)

        # 添加线程状态显示区
        self.thread_frame = ttk.LabelFrame(self.main_frame, text="多线程状态", padding="10")
        self.thread_frame.grid(row=0, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))
        self.thread_status = tk.StringVar(value="线程池: 活动")
        ttk.Label(self.thread_frame, textvariable=self.thread_status).grid(row=0, column=0, sticky=tk.W)
        self.task_count = tk.StringVar(value="任务数: 0")
        ttk.Label(self.thread_frame, textvariable=self.task_count).grid(row=0, column=1, sticky=tk.W, padx=10)

        # 快捷键说明区
        self.shortcut_frame = ttk.LabelFrame(self.main_frame, text="快捷键说明", padding="10")
        self.shortcut_frame.grid(row=1, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))
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
        
        # 日志区
        self.log_frame = ttk.LabelFrame(self.main_frame, text="日志", padding="10")
        self.log_frame.grid(row=2, column=1, padx=5, pady=5, sticky=(tk.W, tk.E))
        self.log_text = tk.Text(self.log_frame, height=8, width=80)
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E))
        self.log_text.configure(state='disabled')
        self.log_scroll = ttk.Scrollbar(self.log_frame, orient="vertical", command=self.log_text.yview)
        self.log_scroll.grid(row=0, column=1, sticky=(tk.N, tk.S))
        self.log_text.configure(yscrollcommand=self.log_scroll.set)
        self.log_text.tag_configure('error', foreground='red')
        self.log_text.tag_configure('warning', foreground='orange')
        self.log_text.tag_configure('info', foreground='black')
        
    def bind_shortcuts(self) -> None:
        # 设备默认设置快捷键
        self.bind('<Control-KeyPress-q>', lambda e: self.on_closing())

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
        self.bind('<Control-KeyPress-m>', lambda e: self.async_task('reset_mc_pid', PyrplInstr.p3_pid_reset, 0))
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
        
    def process_queue(self):
        """处理任务结果队列"""
        try:
            # 更新任务计数
            self.task_count.set(f"任务数: {self.result_queue.qsize()}")
            
            # 处理队列中的所有消息，但最多处理10个，避免UI阻塞
            for _ in range(min(10, self.result_queue.qsize())):
                message = self.result_queue.get_nowait()
                self.handle_task_result(message)
                self.result_queue.task_done()
        except queue.Empty:
            pass
        finally:
            # 继续处理队列
            self.after(COMMON_UPDATE_INTERVAL, self.process_queue)
    
    def handle_task_result(self, message):
        """处理任务结果"""
        if len(message) == 3:  # 包含异常
            task_id, result, exception = message
            logging.error(f"Task {task_id} failed: {exception}")
            return
            
        task_id, result = message
        
        # 根据任务ID处理结果
        if task_id == 'pid_values':
            self.update_pid_display(result)
        elif task_id == 'laser_wavelength':
            self.laser_nkt_actwl.set(f"{result:.4f}")
        elif task_id == 'laser_status':
            self.laser_nkt_status.set(result)
        elif task_id == 'osc_vavg':
            self.osc_vavg1.set(result)
            # 如果锁定VAVG，则在这里处理PID计算
            if self.check_lockvavg_var.get() == 'Lock VAVG':
                self.update_pid_vavg()
        elif task_id == 'ws_setup':
            center_wl_1, center_wl_2 = result
            self.band1_wl.set(f"{center_wl_1:.5f} nm")
            self.band2_wl.set(f"{center_wl_2:.5f} nm")
            # 更新toptica设置
            self.async_task('set_toptica', 
                            self.device_manager.set_toptica,
                            center_wl_2 + toptica1_wl_bias, 
                            center_wl_1 + toptica2_wl_bias)
    
    def update_pid_display(self, pid_values):
        """更新PID值显示"""
        self.p1_pid0_ival.set(f"{pid_values['p1_pid0']:.2f}")
        self.p1_pid1_ival.set(f"{pid_values['p1_pid1']:.2f}")
        self.p2_pid0_ival.set(f"{pid_values['p2_pid0']:.2f}")
        self.p2_pid1_ival.set(f"{pid_values['p2_pid1']:.2f}")
        self.p3_pid0_ival.set(f"{pid_values['p3_pid0']:.2f}")
        
        # 自动复位判断
        if self.check_autolock_var.get() == 'Auto Reset':
            self.check_and_reset(pid_values['p1_pid0'], PyrplInstr.p1_pid_reset, 0)
            self.check_and_reset(pid_values['p1_pid1'], PyrplInstr.p1_pid_reset, 1)
            self.check_and_reset(pid_values['p2_pid0'], PyrplInstr.p2_pid_reset, 0)
            self.check_and_reset(pid_values['p2_pid1'], PyrplInstr.p2_pid_reset, 1)
    
    def start_periodic_updates(self):
        """启动所有定期更新任务"""
        # PID值更新
        self.start_periodic_task('pid_values', 
                                 UPDATE_INTERVAL_AUTO_RESET,
                                 self.device_manager.get_pid_values)
        
        # 激光器状态更新
        self.start_periodic_task('laser_status', 
                                 UPDATE_INTERVAL_LASER_STATUS,
                                 self.device_manager.get_laser_status)
        
        # 激光器波长更新
        self.start_periodic_task('laser_wavelength', 
                                 UPDATE_INTERVAL_LASER_WL,
                                 self.device_manager.get_laser_wavelength)
        
        # 示波器电压更新
        self.start_periodic_task('osc_vavg', 
                                 UPDATE_INTERVAL_OSC_VAVG,
                                 self.device_manager.get_osc_vavg, 1)
    
    def start_periodic_task(self, task_id, interval, func, *args, **kwargs):
        """启动周期性任务"""
        with self.update_tasks_lock:
            self.update_tasks[task_id] = True
        
        def task_loop():
            with self.update_tasks_lock:
                if not self.update_tasks.get(task_id, False):
                    return
            
            self.device_manager.async_execute(task_id, func, *args, **kwargs)
            
            # 继续循环
            self.after(interval, task_loop)
        
        # 启动第一次任务
        self.after(interval, task_loop)
    
    def async_task(self, task_id, func, *args, **kwargs):
        """异步执行任务"""
        return self.device_manager.async_execute(task_id, func, *args, **kwargs)
    
    def on_emission_changed(self):
        """激光器发射状态变化处理"""
        current_emission = self.check_emission_var.get()
        if current_emission != self._last_emission:
            if current_emission == 'Emission ON':
                self.async_task('set_emission_on', self.device_manager.set_emission, True)
            else:
                self.async_task('set_emission_off', self.device_manager.set_emission, False)
            self._last_emission = current_emission
    
    def on_lockvavg_changed(self):
        """VAVG锁定状态变化处理"""
        current_lockvavg = self.check_lockvavg_var.get()
        if current_lockvavg != self._last_lockvavg:
            logging.info(f"VAVG lock status changed to: {current_lockvavg}")
            if current_lockvavg == 'Lock VAVG':
                self.lockvavg_integral = 0
                self.lockvavg_last_error = 0
                self.setpoint_vavg1.set(self.osc_vavg1.get())
            self._last_lockvavg = current_lockvavg
    
    def update_pid_vavg(self):
        """更新VAVG PID控制逻辑"""
        try:
            if self.check_lockvavg_var.get() == 'Lock VAVG':
                error = self.setpoint_vavg1.get() - self.osc_vavg1.get()
                self.lockvavg_integral += error * UPDATE_INTERVAL_OSC_VAVG / 1000.0
                derivative = (error - self.lockvavg_last_error) / (UPDATE_INTERVAL_OSC_VAVG / 1000.0)
                output = self.lockvavg_kp.get() * error + self.lockvavg_ki.get() * self.lockvavg_integral + self.lockvavg_kp.get() * derivative
                max_output = 0.1
                output = max(min(output, max_output), -max_output)
                print(f"VAVG: error={error:.5f}, integral={self.lockvavg_integral:.5f}, derivative={derivative:.5f}, output={output:.5f}")
                self.move_laser_nkt_setwl(output)
                self.lockvavg_last_error = error
                logging.info("Locking VAVG: error=%.5f, integral=%.5f, derivative=%.5f, output=%.5f", 
                             error, self.lockvavg_integral, derivative, output)
        except Exception as e:
            logging.error("Error updating PID VAVG: %s", e)
            
    def check_and_reset(self, pid_value, reset_func, channel):
        """当PID值超过阈值时进行复位"""
        if abs(pid_value) > THRESHOLD_AUTO_RESET:
            try:
                self.async_task(f'reset_pid_{channel}', reset_func, channel)
                logging.info("Reset PID channel %d with value %.2f", channel, pid_value)
            except Exception as e:
                logging.error("Failed to reset PID channel %d: %s", channel, e)
    
    def ws_toptica_set(self, n):
        """设置WaveShaper和Toptica"""
        try:
            # 异步执行WaveShaper设置
            self.async_task('ws_setup', 
                           self.device_manager.setup_waveshaper,
                           self.pump_wl.get(), FSR * n, 40,
                           [self.band1_att.get(), self.pump_att.get(), self.band2_att.get()],
                           [self.band1_degree.get(), self.pump_degree.get(), self.band2_degree.get()])
            
        except Exception as e:
            logging.error("Error in ws_toptica_set: %s", e)
            
    def setup_device(self, device_number):
        """根据设备号设置对应设备"""
        try:
            if device_number == 1:
                self.async_task('setup_p1', PyrplInstr.p1_setup)
                self.pump_rp_state.set('Pump&P_ref Default')
            elif device_number == 2:
                self.async_task('setup_p2', PyrplInstr.p2_setup)
                self.local_rp_state.set('Local Default')
            elif device_number == 3:
                self.async_task('setup_p3', PyrplInstr.p3_setup)
                self.MC_FL_rp_state.set('MC_FL Default')
            elif device_number == 4:
                self.async_task('setup_p4', PyrplInstr.p4_setup)
                self.MC_SL_rp_state.set('MC_SL Default')
        except Exception as e:
            logging.error("Error setting up device %d: %s", device_number, e)
            
    def setup_all_devices(self):
        """设置所有设备为默认状态"""
        self.setup_device(1)
        self.setup_device(2)
        self.setup_device(3)
        self.setup_device(4)
        
    def reset_all_pid(self):
        """复位所有PID"""
        try:
            self.async_task('reset_p1_pid0', PyrplInstr.p1_pid_reset, 0)
            self.async_task('reset_p1_pid1', PyrplInstr.p1_pid_reset, 1)
            self.async_task('reset_p2_pid0', PyrplInstr.p2_pid_reset, 0)
            self.async_task('reset_p2_pid1', PyrplInstr.p2_pid_reset, 1)
        except Exception as e:
            logging.error("Error resetting all PID: %s", e)
            
    def start_ramp_all(self):
        """启动所有设备的ramping"""
        try:
            # 使用多个异步任务并行执行
            tasks = [
                ('p1_pid_paused0', PyrplInstr.p1_pid_paused, 0),
                ('p1_pid_paused1', PyrplInstr.p1_pid_paused, 1),
                ('p2_pid_paused0', PyrplInstr.p2_pid_paused, 0),
                ('p2_pid_paused1', PyrplInstr.p2_pid_paused, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            tasks = [
                ('p1_pid_reset0', PyrplInstr.p1_pid_reset, 0),
                ('p1_pid_reset1', PyrplInstr.p1_pid_reset, 1),
                ('p2_pid_reset0', PyrplInstr.p2_pid_reset, 0),
                ('p2_pid_reset1', PyrplInstr.p2_pid_reset, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            tasks = [
                ('p1_ramp_on0', PyrplInstr.p1_ramp_on, 0),
                ('p1_ramp_on1', PyrplInstr.p1_ramp_on, 1),
                ('p2_ramp_on0', PyrplInstr.p2_ramp_on, 0),
                ('p2_ramp_on1', PyrplInstr.p2_ramp_on, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local Ramping')
        except Exception as e:
            logging.error("Error starting ramp: %s", e)
            
    def lock_all(self):
        """锁定所有PID"""
        try:
            tasks = [
                ('p1_ramp_off0', PyrplInstr.p1_ramp_off, 0),
                ('p1_ramp_off1', PyrplInstr.p1_ramp_off, 1),
                ('p2_ramp_off0', PyrplInstr.p2_ramp_off, 0),
                ('p2_ramp_off1', PyrplInstr.p2_ramp_off, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            tasks = [
                ('p1_pid_unpaused0', PyrplInstr.p1_pid_unpaused, 0),
                ('p1_pid_unpaused1', PyrplInstr.p1_pid_unpaused, 1),
                ('p2_pid_unpaused0', PyrplInstr.p2_pid_unpaused, 0),
                ('p2_pid_unpaused1', PyrplInstr.p2_pid_unpaused, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            self.pump_rp_state.set('Pump&P_ref Locked')
            self.local_rp_state.set('Local Locked')
        except Exception as e:
            logging.error("Error locking PID: %s", e)
            
    def miniramp_local(self):
        """Local PID的miniramp操作"""
        try:
            tasks = [
                ('p1_pid_paused0', PyrplInstr.p1_pid_paused, 0),
                ('p1_pid_paused1', PyrplInstr.p1_pid_paused, 1),
                ('p2_pid_paused0', PyrplInstr.p2_pid_paused, 0),
                ('p2_pid_paused1', PyrplInstr.p2_pid_paused, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            tasks = [
                ('p1_pid_reset0', PyrplInstr.p1_pid_reset, 0),
                ('p1_pid_reset1', PyrplInstr.p1_pid_reset, 1),
                ('p2_pid_reset0', PyrplInstr.p2_pid_reset, 0),
                ('p2_pid_reset1', PyrplInstr.p2_pid_reset, 1)
            ]
            
            for task_id, func, arg in tasks:
                self.async_task(task_id, func, arg)
                
            self.async_task('p1_ramp_on0', PyrplInstr.p1_ramp_on, 0)
            self.async_task('p1_ramp_on1', PyrplInstr.p1_ramp_on, 1)
            self.async_task('p2_miniramp_on', PyrplInstr.p2_miniramp_on, 0)
            self.async_task('p2_ramp_off1', PyrplInstr.p2_ramp_off, 1)
            
            self.pump_rp_state.set('Pump&P_ref Ramping')
            self.local_rp_state.set('Local1 Miniramping')
        except Exception as e:
            logging.error("Error in miniramp for local: %s", e)
            
    def start_mc_ramp(self):
        """启动MC PID的ramping"""
        try:
            self.async_task('p3_pid_paused', PyrplInstr.p3_pid_paused, 0)
            self.async_task('p3_pid_reset', PyrplInstr.p3_pid_reset, 0)
            self.async_task('p3_ramp_on', PyrplInstr.p3_ramp_on, 0)
            self.async_task('p3_ramp_off', PyrplInstr.p3_ramp_off, 1)
            self.MC_FL_rp_state.set('MC Ramping')
        except Exception as e:
            logging.error("Error starting MC ramp: %s", e)
            
    def coarse_lock_mc(self):
        """MC PID的coarse locking"""
        try:
            self.async_task('p3_ramp_off', PyrplInstr.p3_ramp_off, 0)
            self.async_task('slow_ramp_on', PyrplInstr.slow_ramp, 'on')
            self.async_task('p3_pid_unpaused', PyrplInstr.p3_pid_unpaused, 0)
            self.MC_FL_rp_state.set('MC Coarse Locking')
        except Exception as e:
            logging.error("Error in MC coarse lock: %s", e)
            
    def fine_lock_mc(self):
        """MC PID的fine locking"""
        try:
            self.async_task('slow_ramp_off', PyrplInstr.slow_ramp, 'off')
            self.async_task('p3_pid_reset', PyrplInstr.p3_pid_reset, 0)
            self.async_task('p3_pid_unpaused', PyrplInstr.p3_pid_unpaused, 0)
            self.MC_FL_rp_state.set('MC Fine Locking')
        except Exception as e:
            logging.error("Error in MC fine lock: %s", e)
            
    def set_sideband(self, sideband, psg_frequency, psg_power):
        """设置PSG与WS的sideband"""
        try:
            # 异步执行PSG设置
            self.async_task('set_psg', 
                           self.device_manager.setup_psg,
                           psg_frequency, psg_power)
            
            # 异步执行WS设置
            self.ws_toptica_set(sideband)
            
            # 更新界面显示
            self.band_num.set(f'Side Band {sideband}')
        except Exception as e:
            logging.error("Error setting sideband %d: %s", sideband, e)

    def set_laser_nkt_wavelength(self):
        """设置NKT激光器波长"""
        try:
            self.async_task('set_laser_wavelength', 
                           self.device_manager.set_laser_wavelength,
                           self.laser_nkt_setwl.get())
        except Exception as e:
            logging.error("Error setting NKT laser wavelength: %s", e)

    def move_laser_nkt_setwl(self, value=0.001):
        """调整NKT激光器波长"""
        self.laser_nkt_setwl.set(self.laser_nkt_setwl.get() + value)
        self.set_laser_nkt_wavelength()


if __name__ == "__main__":
    app = ControlCenterGUI()
    app.mainloop()
    