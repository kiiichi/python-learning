import threading
import time
import tkinter as tk
from tkinter import ttk
import logging

# 设备控制相关导入
from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias
from Ctrl_LaserNkt import *
from Ctrl_HttpInstr import *
from Ctrl_ScpiInstr import *
from Ctrl_PyrplInstr import *

logging.basicConfig(level=logging.INFO)

# 定义更新间隔
UPDATE_INTERVAL_LASER = 1  # 激光器查询频率 (秒)
UPDATE_INTERVAL_OSC_VAVG = 2  # 示波器查询频率 (秒)
UPDATE_INTERVAL_PID = 0.5  # PID 控制间隔 (秒)

class ControlCenterGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Control Center GUI")

        # 界面布局
        self.main_frame = ttk.Frame(self, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # 初始化变量
        self.init_variables()
        self.create_regions()

        # 启动多线程任务
        self.start_threads()

    def init_variables(self):
        """初始化 GUI 变量"""
        self.laser_nkt_actwl = tk.StringVar(value='default')
        self.laser_nkt_setwl = tk.DoubleVar(value=1549.7420)
        self.osc_vavg1 = tk.DoubleVar(value=0)
        self.setpoint_vavg1 = tk.DoubleVar(value=0)

        # PID 相关
        self.pid_kp = 0.1
        self.pid_ki = 0.01
        self.pid_kd = 0.05
        self.pid_integral = 0
        self.pid_last_error = 0

    def create_regions(self):
        """创建 GUI 组件"""
        self.laser_label = ttk.Label(self.main_frame, text="Laser WL:")
        self.laser_label.grid(row=0, column=0)
        self.laser_value = ttk.Label(self.main_frame, textvariable=self.laser_nkt_actwl)
        self.laser_value.grid(row=0, column=1)

        self.osc_label = ttk.Label(self.main_frame, text="Oscilloscope VAVG:")
        self.osc_label.grid(row=1, column=0)
        self.osc_value = ttk.Label(self.main_frame, textvariable=self.osc_vavg1)
        self.osc_value.grid(row=1, column=1)

        self.setpoint_label = ttk.Label(self.main_frame, text="Setpoint VAVG:")
        self.setpoint_label.grid(row=2, column=0)
        self.setpoint_value = ttk.Label(self.main_frame, textvariable=self.setpoint_vavg1)
        self.setpoint_value.grid(row=2, column=1)

    def start_threads(self):
        """启动后台线程"""
        threading.Thread(target=self.laser_monitor, daemon=True).start()
        threading.Thread(target=self.oscilloscope_monitor, daemon=True).start()
        threading.Thread(target=self.pid_controller, daemon=True).start()

    def laser_monitor(self):
        """后台线程：定期更新激光器波长"""
        while True:
            try:
                wl = nkt_read_wavelength()
                self.after(0, lambda: self.laser_nkt_actwl.set(f"{wl:.4f} nm"))
            except Exception as e:
                logging.error(f"Error updating laser wavelength: {e}")
            time.sleep(UPDATE_INTERVAL_LASER)

    def oscilloscope_monitor(self):
        """后台线程：定期更新示波器 VAVG"""
        while True:
            try:
                vavg = query_osc_vavg(1)
                self.after(0, lambda: self.osc_vavg1.set(vavg))
            except Exception as e:
                logging.error(f"Error reading oscilloscope VAVG: {e}")
            time.sleep(UPDATE_INTERVAL_OSC_VAVG)

    def pid_controller(self):
        """后台线程：基于 PID 调整激光器波长"""
        while True:
            try:
                current_vavg = self.osc_vavg1.get()
                target_vavg = self.setpoint_vavg1.get()
                error = target_vavg - current_vavg

                # 计算 PID
                self.pid_integral += error * UPDATE_INTERVAL_PID
                derivative = (error - self.pid_last_error) / UPDATE_INTERVAL_PID
                output = self.pid_kp * error + self.pid_ki * self.pid_integral + self.pid_kd * derivative

                # 限制调整步长
                max_adjustment = 0.001
                output = max(min(output, max_adjustment), -max_adjustment)

                # 调整激光器波长
                self.after(0, lambda: self.move_laser_nkt_setwl(output))

                self.pid_last_error = error
                logging.info(f"PID 调整: error={error:.4f}, 调整量={output:.6f}")

            except Exception as e:
                logging.error(f"PID 控制出错: {e}")

            time.sleep(UPDATE_INTERVAL_PID)

    def move_laser_nkt_setwl(self, value: float):
        """调整激光器波长"""
        new_wl = self.laser_nkt_setwl.get() + value
        self.laser_nkt_setwl.set(new_wl)
        try:
            nkt_write_wl(new_wl)
        except Exception as e:
            logging.error(f"Error setting laser wavelength: {e}")

if __name__ == "__main__":
    app = ControlCenterGUI()
    app.mainloop()
