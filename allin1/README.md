# 如何正确安装Pyrpl

1. 确认拥有 python 2.7|3.4|3.5|3.6

2. 使用正确版本的 python 创建虚拟环境

		python路径\python -m venv .venv

3. 升级 pip 至 20.1

		python -m pip install --upgrade pip==20.1

4. 安装模组

		pip install numpy scipy paramiko pandas nose PyQt5<=5.14 qtpy<=1.9 pyqtgraph pyyaml nbconvert

5. 导航到pyrpl目录

		cd pyrpl-main

6. 运行 setup.py

		python setup.py develop
