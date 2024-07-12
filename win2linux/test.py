import tkinter as tk
from tkinter import ttk, messagebox
import paramiko
import time
import os

# 定义函数来执行SSH命令
def execute_ssh_command(ssh, command):
    stdin, stdout, stderr = ssh.exec_command(command)
    output = stdout.read().decode()
    error = stderr.read().decode()
    return output, error

# 更新输出框内容
def update_output(text):
    output_text.insert(tk.END, text + "\n")
    output_text.see(tk.END)

# 定义执行命令的函数
def run_command1():
    try:
        # 获取输入的配置信息
        hostname = hostname_entry.get()
        username = username_entry.get()
        password = password_entry.get()
        TX_fpga = TX_fpga_entry.get()

        # 创建SSH连接
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname, username=username, password=password)

        # 运行命令1
        command1 = f"cat {TX_fpga} > /dev/xdevcfg"
        output1, error1 = execute_ssh_command(ssh, command1)
        if error1:
            update_output(f"Error in ssh_command1: {error1}")
        else:
            update_output(f"ssh_command callback:\n {output1}")

    except Exception as e:
        update_output(f"An error occurred: {e}")
    finally:
        ssh.close()

def run_command2():
    try:
        # 获取输入的配置信息
        hostname = hostname_entry.get()
        username = username_entry.get()
        password = password_entry.get()
        data_file = data_file_entry.get()
        sleep_time = sleep_time_entry.get()
        output_file_prefix = output_file_prefix_entry.get()

        # 创建SSH连接
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname, username=username, password=password)

        # 运行命令2
        command2 = f"./tx {data_file} {sleep_time} {output_file_prefix}"
        output2, error2 = execute_ssh_command(ssh, command2)
        if error2:
            update_output(f"Error in ssh_command2: {error2}")
            return
        else:
            update_output(f"ssh_command callback:\n {output2}")

    except Exception as e:
        update_output(f"An error occurred: {e}")
    finally:
        ssh.close()

def run_command3():
    try:
        # 获取输入的配置信息
        hostname = hostname_entry.get()
        username = username_entry.get()
        password = password_entry.get()
        local_dir = local_dir_entry.get()
        remote_dir = remote_dir_entry.get()
        output_file_prefix = output_file_prefix_entry.get()

        # 创建SSH连接
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname, username=username, password=password)

        # SCP下载文件
        remote_file = f"{output_file_prefix}.csv"
        local_file = os.path.join(local_dir, f"{output_file_prefix}.csv")
        
        with paramiko.Transport((hostname, 22)) as transport:
            transport.connect(username=username, password=password)
            with paramiko.SFTPClient.from_transport(transport) as sftp:
                sftp.get(remote_file, local_file)
        
        if os.path.exists(local_file) and os.path.getsize(local_file) > 0:
            update_output(f"File {output_file_prefix}.csv downloaded successfully to {local_dir}")

            # 删除远程文件
            command3 = f"rm {remote_file}"
            output3, error3 = execute_ssh_command(ssh, command3)
            if error3:
                update_output(f"Error in ssh_command3: {error3}")
            else:
                update_output(f"ssh_command callback:\n {output3}")
        else:
            update_output("File download failed or file is empty.")

    except Exception as e:
        update_output(f"An error occurred: {e}")
    finally:
        ssh.close()

# 创建主窗口
root = tk.Tk()
root.title("SSH Command Executor")
frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

# 创建输入字段
ttk.Label(frame, text="Hostname:").grid(row=0, column=0, sticky=tk.W)
hostname_entry = ttk.Entry(frame)
hostname_entry.grid(row=0, column=1, sticky=tk.EW)

ttk.Label(frame, text="Username:").grid(row=1, column=0, sticky=tk.W)
username_entry = ttk.Entry(frame)
username_entry.grid(row=1, column=1, sticky=tk.EW)

ttk.Label(frame, text="Password:").grid(row=2, column=0, sticky=tk.W)
password_entry = ttk.Entry(frame, show="*")
password_entry.grid(row=2, column=1, sticky=tk.EW)

ttk.Label(frame, text="TX_fpga:").grid(row=3, column=0, sticky=tk.W)
TX_fpga_entry = ttk.Entry(frame)
TX_fpga_entry.grid(row=3, column=1, sticky=tk.EW)

ttk.Label(frame, text="Data File:").grid(row=4, column=0, sticky=tk.W)
data_file_entry = ttk.Entry(frame)
data_file_entry.grid(row=4, column=1, sticky=tk.EW)

ttk.Label(frame, text="Sleep Time:").grid(row=5, column=0, sticky=tk.W)
sleep_time_entry = ttk.Entry(frame)
sleep_time_entry.grid(row=5, column=1, sticky=tk.EW)

ttk.Label(frame, text="Output File Prefix:").grid(row=6, column=0, sticky=tk.W)
output_file_prefix_entry = ttk.Entry(frame)
output_file_prefix_entry.grid(row=6, column=1, sticky=tk.EW)

ttk.Label(frame, text="Local Directory:").grid(row=7, column=0, sticky=tk.W)
local_dir_entry = ttk.Entry(frame)
local_dir_entry.grid(row=7, column=1, sticky=tk.EW)

ttk.Label(frame, text="Remote Directory:").grid(row=8, column=0, sticky=tk.W)
remote_dir_entry = ttk.Entry(frame)
remote_dir_entry.grid(row=8, column=1, sticky=tk.EW)

# 创建输出框
output_text = tk.Text(frame, height=20)
output_text.grid(row=12, column=0, columnspan=2)

# 创建按钮
command1_button = ttk.Button(frame, text="Run FPGA file", command=run_command1, width=20)
command1_button.grid(row=9, column=0, pady=10, sticky=tk.W)

command2_button = ttk.Button(frame, text="Start TX", command=run_command2, width=20)
command2_button.grid(row=10, column=0, pady=10, sticky=tk.W)

command3_button = ttk.Button(frame, text="Download time file", command=run_command3, width=20)
command3_button.grid(row=11, column=0, pady=10, sticky=tk.W)

# 设置网格布局权重
frame.grid_columnconfigure(0, weight=1)
frame.grid_columnconfigure(1, weight=10)

# 设置默认值
hostname_entry.insert(0, "192.168.1.15")
username_entry.insert(0, "root")
password_entry.insert(0, "root")
TX_fpga_entry.insert(0, "PDE_code/transmitterASK.bit")
data_file_entry.insert(0, "data/data100.txt")
sleep_time_entry.insert(0, "400")
output_file_prefix_entry.insert(0, "loop_times")
local_dir_entry.insert(0, r"C:\Users\1550\Desktop\PDE_data")
remote_dir_entry.insert(0, "/root")

# 启动主循环
root.mainloop()
