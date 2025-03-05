from time import sleep
import tkinter as tk
from tkinter import ttk
import logging

# 假定以下模块中的函数和变量已定义并可用
from pyrpl_rpctrl import *
from http_instctrl import *
from scpi_instctrl import *
from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias

logging.basicConfig(level=logging.INFO)

class ControlCenterGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Control Center GUI")
        self.frame = ttk.Frame(self, padding="10")
        self.frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.init_variables()
        self.create_widgets()
        self.bind_shortcuts()
        
        # 定时更新 PID 数据
        self.after(100, self.update_pid_values)
        
    def init_variables(self):
        # 各设备状态变量
        self.pump_rp_state = tk.StringVar(value='pump_rp_state')
        self.local_rp_state = tk.StringVar(value='local_rp_state')
        self.MC_FL_rp_state = tk.StringVar(value='MC_FL_rp_state')
        self.MC_SL_rp_state = tk.StringVar(value='MC_SL_rp_state')
        
        # PID 测量值显示变量
        self.p1_pid0_ival = tk.StringVar(value='Pump pid ival: 0')
        self.p1_pid1_ival = tk.StringVar(value='P_ref pid ival: 0')
        self.p2_pid0_ival = tk.StringVar(value='Local pid0 ival: 0')
        self.p2_pid1_ival = tk.StringVar(value='Local pid1 ival: 0')
        self.p3_pid0_ival = tk.StringVar(value='MC pid ival: 0')
        
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
        
    def create_widgets(self):
        # 设备状态显示区
        ttk.Label(self.frame, textvariable=self.pump_rp_state).grid(column=0, row=0, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.local_rp_state).grid(column=0, row=1, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.MC_FL_rp_state).grid(column=0, row=2, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.MC_SL_rp_state).grid(column=0, row=3, sticky=tk.W)
        
        # PID 测量值显示区
        ttk.Label(self.frame, text="PID Ival").grid(column=1, row=0, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.p1_pid0_ival).grid(column=1, row=1, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.p1_pid1_ival).grid(column=1, row=2, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.p2_pid0_ival).grid(column=1, row=3, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.p2_pid1_ival).grid(column=1, row=4, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.p3_pid0_ival).grid(column=1, row=5, sticky=tk.W)
        
        # 波长及相关参数设置区
        ttk.Label(self.frame, text="Wavelength (nm)").grid(column=2, row=0, sticky=tk.W)
        ttk.Entry(self.frame, textvariable=self.pump_wl, width=9, justify="center").grid(column=2, row=1)
        ttk.Label(self.frame, textvariable=self.band1_wl).grid(column=2, row=2, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.band2_wl).grid(column=2, row=3, sticky=tk.W)
        ttk.Label(self.frame, textvariable=self.band_num).grid(column=2, row=4, sticky=tk.W)
        
        # 衰减设置区
        ttk.Label(self.frame, text="Attenuation (dB)").grid(column=3, row=0, sticky=tk.W)
        ttk.Entry(self.frame, textvariable=self.pump_att, width=9, justify="center").grid(column=3, row=1)
        ttk.Entry(self.frame, textvariable=self.band1_att, width=9, justify="center").grid(column=3, row=2)
        ttk.Entry(self.frame, textvariable=self.band2_att, width=9, justify="center").grid(column=3, row=3)
        
        # 相位设置区
        ttk.Label(self.frame, text="Phase (degree)").grid(column=4, row=0, sticky=tk.W)
        ttk.Entry(self.frame, textvariable=self.pump_degree, width=9, justify="center").grid(column=4, row=1)
        ttk.Entry(self.frame, textvariable=self.band1_degree, width=9, justify="center").grid(column=4, row=2)
        ttk.Entry(self.frame, textvariable=self.band2_degree, width=9, justify="center").grid(column=4, row=3)
        
        # 自动复位检查按钮
        ttk.Checkbutton(self.frame, text="Auto Reset",
                        variable=self.check_autolock_var,
                        onvalue="Auto Reset", offvalue="Manual Reset").grid(column=0, row=4, sticky=tk.W)
        
        # 快捷键说明信息
        info_texts = [
            "------------------------------------------------ SHORT CUT -------------------------------------------------",
            "default rp: ctrl + ( 1 = pump, 2 = local, 3 = MC_FL, 4 = MC_SL, 0 = ALL)",
            "Pump&Local rp: ctrl+z = ramp, ctrl+r = reset, ctrl+f = lock, ctrl+c = miniramp",
            "MC rp: ctrl+n = ramp, ctrl+m = reset, ctrl+, = coarselock, ctrl+. = finelock",
            "PSG and WS: ctrl + shift + 1~9 (Toptica as local) | alt + 1~9 (EOcomb as local) = sideband 1-9"
        ]
        for i, text in enumerate(info_texts, start=6):
            ttk.Label(self.frame, text=text).grid(column=0, row=i, columnspan=5, sticky=tk.W)
            
    def bind_shortcuts(self):
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
        
        # Sideband 快捷键（Alt 与 Control 修饰键分别对应不同的 PSG 设置）
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
        
    def update_pid_values(self):
        """获取 PID 值并更新界面，同时检查是否需要自动复位。"""
        try:
            # 读取各 PID 当前的值
            p1_val0 = p1_pid0.ival
            p1_val1 = p1_pid1.ival
            p2_val0 = p2_pid0.ival
            p2_val1 = p2_pid1.ival
            p3_val0 = p3_pid0.ival
            
            # 更新显示
            self.p1_pid0_ival.set(f"Pump: {p1_val0:.2f}")
            self.p1_pid1_ival.set(f"P_ref: {p1_val1:.2f}")
            self.p2_pid0_ival.set(f"Local0: {p2_val0:.2f}")
            self.p2_pid1_ival.set(f"Local1: {p2_val1:.2f}")
            self.p3_pid0_ival.set(f"MC: {p3_val0:.2f}")
            
            # 自动复位判断
            if self.check_autolock_var.get() == 'Auto Reset':
                self.check_and_reset(p1_val0, p1_pid_reset, 0)
                self.check_and_reset(p1_val1, p1_pid_reset, 1)
                self.check_and_reset(p2_val0, p2_pid_reset, 0)
                self.check_and_reset(p2_val1, p2_pid_reset, 1)
        except Exception as e:
            logging.error("Error updating PID values: %s", e)
            
        self.after(100, self.update_pid_values)
        
    def check_and_reset(self, pid_value, reset_func, channel):
        """当 PID 值超过阈值时进行复位。"""
        if abs(pid_value) > 0.6:
            try:
                reset_func(channel)
                logging.info("Reset PID channel %d with value %.2f", channel, pid_value)
            except Exception as e:
                logging.error("Failed to reset PID channel %d: %s", channel, e)
                
    def ws_toptica_set(self, n):
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
            
    def setup_device(self, device_number):
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
            
    def setup_all_devices(self):
        """设置所有设备为默认状态。"""
        self.setup_device(1)
        self.setup_device(2)
        self.setup_device(3)
        self.setup_device(4)
        self.pump_rp_state.set('Pump&P_ref Default')
        self.local_rp_state.set('Local Default')
        self.MC_FL_rp_state.set('MC_FL Default')
        self.MC_SL_rp_state.set('MC_SL Default')
        
    def reset_all_pid(self):
        """复位 Pump 与 Local 的所有 PID 通道。"""
        try:
            p1_pid_reset(0)
            p1_pid_reset(1)
            p2_pid_reset(0)
            p2_pid_reset(1)
        except Exception as e:
            logging.error("Error resetting all PID: %s", e)
            
    def start_ramp_all(self):
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
            
    def lock_all(self):
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
            
    def miniramp_local(self):
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
            
    def start_mc_ramp(self):
        """开始 MC PID 的 ramping 操作。"""
        try:
            p3_pid_paused(0)
            p3_pid_reset(0)
            p3_ramp_on(0)
            p3_ramp_off(1)
            self.MC_FL_rp_state.set('MC Ramping')
        except Exception as e:
            logging.error("Error starting MC ramp: %s", e)
            
    def coarse_lock_mc(self):
        """MC PID 进行 coarse locking。"""
        try:
            p3_ramp_off(0)
            slow_ramp('on')
            p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Coarse Locking')
        except Exception as e:
            logging.error("Error in MC coarse lock: %s", e)
            
    def fine_lock_mc(self):
        """MC PID 进行 fine locking。"""
        try:
            slow_ramp('off')
            p3_pid_reset(0)
            p3_pid_unpaused(0)
            self.MC_FL_rp_state.set('MC Fine Locking')
        except Exception as e:
            logging.error("Error in MC fine lock: %s", e)
            
    def set_sideband(self, sideband, psg_frequency, psg_power):
        """设置 PSG 与 WS 的 sideband，并更新显示。"""
        try:
            ctrl_psg(psg_frequency, psg_power)
            self.ws_toptica_set(sideband)
            self.band_num.set(f'Side Band {sideband}')
        except Exception as e:
            logging.error("Error setting sideband %d: %s", sideband, e)

if __name__ == "__main__":
    app = ControlCenterGUI()
    app.mainloop()
