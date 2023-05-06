# 使用说明

## 1. 部署虚拟环境

### 1.1 具体操作

确认有pip

    py -m pip --version

安装并更新 pip, setuptools, and wheel

    py -m pip install --upgrade pip setuptools wheel

创建虚拟环境

    py -m venv tutorial_env

激活虚拟环境

>windows中，需要允许计算机运行脚本，详见 https:/go.microsoft.com/fwlink/?LinkID=135170

在管理员身份的 powershell 中：

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

在vscode上，运行：

    tutorial-env\Scripts\Activate.ps1

或选择 'tutorial-env\Scripts\python.exe' 作为interpreter

安装环境需要的模块

    pip install -r requirements.txt

### 1.2 相关的基本命令

`pip` 是首选的安装程序。从Python 3.4开始，它默认包含在Python二进制安装程序中。

*virtual environment* 是一种半隔离的 Python 环境，允许为特定的应用安装各自的包，而不是安装到整个系统。

`venv` 是创建虚拟环境的标准工具，从 Python 3.3 开始成为 Python 的组成部分。 从 Python 3.4 开始，它会默认安装 `pip` 到所创建的全部虚拟环境。

`virtualenv` 是 `venv` 的第三方替代（及其前身）。 它允许在 Python 3.4 之前的版本中使用虚拟环境，那些版本或是完全不提供 `venv`，或是不会自动安装 pip 到所创建的虚拟环境。

#### 1.2.1 pip 基本命令
>pip 有许多子命令: "install", "uninstall", "freeze" 等等。
详见python文档：安装Python模块

列出当前环境已安装的模块：

    pip list

安装模块

    python -m pip install SomePackage

升级模块

    python -m pip install --upgrade SomePackage

生成 'requirements.txt'

    pip freeze > requirements.txt

按 'requirements.txt' 安装模块

    pip install -r requirements.txt

按 'requirements.txt' 卸载模块

    pip uninstall -r requirements.txt
    or
    pip uninstall -r requirements.txt -y

当提示权限不够时，前面加上sudo

### 1.2.2 venv 基本命令

要创建虚拟环境，请确定要放置它的目录，并将 `venv` 模块作为脚本运行目录路径:

    python3 -m venv tutorial-env

这将创建 tutorial-env 目录，如果它不存在的话，并在其中创建包含 Python 解释器副本和各种支持文件的目录。

虚拟环境的常用目录位置是 .venv。 这个名称通常会令该目录在你的终端中保持隐藏，从而避免需要对所在目录进行额外解释的一般名称。 它还能防止与某些工具所支持的 .env 环境变量定义文件发生冲突。

创建虚拟环境后，您可以激活它。

在Windows上 (CMD)，运行:

    tutorial-env\Scripts\activate.bat

在Unix或MacOS上，运行:

    source tutorial-env/bin/activate

在vscode上，运行：

    tutorial-env\Scripts\Activate.ps1

或选择 'tutorial-env\Scripts\python.exe' 作为interpreter

退出虚拟环境，在终端里运行：

    deactivate







## 2. 正确上传代码库

对于有虚拟环境的代码库，在与虚拟环境相关的文件里只需要上传 'requirements.txt'，其余文件需要在Git项目中定义 .gitignore 文件排除掉。在其他设备上下载代码库后需**重新部署**虚拟环境。

### 2.1 .gitignore文件中的忽略规则

文件 .gitignore 的格式规范如下：
>https://git-scm.com/docs/gitignore

> 所有空行或者以注释符号 ＃ 开头的行都会被 Git 忽略。
> 
> 可以使用标准的 glob 模式匹配。
> 
> 匹配模式最后跟反斜杠（/）说明要忽略的是目录。
> 要忽略指定模式以外的文件或目录，可以在模式前加上惊叹号（!）取反。
>
>> 所谓的 glob 模式是指 shell 所使用的简化了的正则表达式。
>> 星号（*）匹配零个或多个任意字符；
>> [abc]匹配任何一个列在方括号中的字符（这个例子要么匹配一个 a，要么匹配一个 b，要么匹配一个 c）；
>> 问号（?）只匹配一个任意字符；
>> 如果在方括号中使用短划线分隔两个字符，表示所有在这两个字符范围内的都可以匹配（比如 [0-9] 表示匹配所有 0 到 9 的数字）。

### 2.2 常用匹配示例：

`bin/` ：忽略当前路径下的bin文件夹，该文件夹下的所有内容都会被忽略，不忽略 bin 文件

`/bin` ：忽略根目录下的bin文件

`/*.c` ：忽略 cat.c，不忽略 build/cat.c

`debug/*.obj` ： 忽略 debug/io.obj，不忽略 debug/common/io.obj 和 tools/debug/io.obj

`**/foo` ： 忽略/foo, a/foo, a/b/foo等

`a/**/b` ： 忽略a/b, a/x/b, a/x/y/b等

`!/bin/run.sh` ： 不忽略 bin 目录下的 run.sh 文件

`*.log` ： 忽略所有 .log 文件

`config.php` ： 忽略当前路径的 config.php 文件

### 2.3 .gitignore 配置文件示例

```
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/

# add
.idea/
```

# Python(3.11.0) 学习
我见君来，顿觉吾庐，溪山美哉。

### lambda

#### 用法1：结合 **map()** 函数给 *序列* 逐一进行想要的函数操作

> 有三种基本的*序列*类型：list, tuple 和 range 对象。详见 “3.11.0 Documentation » Python 标准库 » 内置类型 » 序列类型”

map() 函数：

描述：

map() 会根据提供的函数对指定序列做映射。
 
第一个参数 function 以参数序列中的每一个元素调用 function 函数，返回包含每次 function 函数返回值的列表。
 
语法：
 
    map(function, iterable, ...)
 
参数：
 
function ----> 函数
 
iterable ----> 一个或多个序列
返回值：
 
Python 2.x 版本返回的是列表

Python 3.x 版本返回的是迭代器

例如：
```
# ======= 一般写法 =======
def square(x)
    return x **2

list(map(square, [1,2,3,4,5]))

# 结果：[1, 4, 9, 16, 25]

# ======= 匿名函数写法 =======
list(map(lambda x: x **2, [1,2,3,4,5]))

# 结果：[1, 4, 9, 16, 25]

list(map(lambda x, y: x +y, [1,2,3,4,5], [5,4,3,2,1]))

# 结果：[6, 6, 6, 6, 6]
```