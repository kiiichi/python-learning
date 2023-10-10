# 使用说明

## 1. 部署虚拟环境

### 1.1. 具体操作

#### 1.1.1. 配置基本环境
确认有pip

    py -m pip --version

安装并更新 pip, setuptools, and wheel

    py -m pip install --upgrade pip setuptools wheel

#### 1.1.2. 进入虚拟环境
创建虚拟环境

    python3 -m venv tutorial_env # 环境名为.venv时可在Git项目中保持隐藏

激活虚拟环境

>windows中，需要允许计算机运行脚本，详见 https:/go.microsoft.com/fwlink/?LinkID=135170

在管理员身份的 powershell 中：

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

在vscode上，运行：

    tutorial_env\Scripts\Activate.ps1

或选择 'tutorial-env\Scripts\python.exe' 作为interpreter

安装环境需要的模块

    pip install -r requirements.txt

|平台|Shell|用于激活虚拟环境的命令|
|---|---|---|
|POSIX|bash/zsh|$ source \<venv>/bin/activate|
|POSIX|fish|$ source \<venv>/bin/activate.fish|
|POSIX|csh/tcsh|$ source \<venv>/bin/activate.csh|
|POSIX|PowerShell|$ \<venv>/bin/Activate.ps1|
|Windows|cmd.exe|C:\ ...venvname... \Scripts\activate.bat|
|Windows|PowerShell|PS C:\ ...venvname... \Scripts\Activate.ps1|




### 1.2. 相关的基本命令

`pip` 是首选的安装程序。从Python 3.4开始，它默认包含在Python二进制安装程序中。

*virtual environment* 是一种半隔离的 Python 环境，允许为特定的应用安装各自的包，而不是安装到整个系统。

`venv` 是创建虚拟环境的标准工具，从 Python 3.3 开始成为 Python 的组成部分。 从 Python 3.4 开始，它会默认安装 `pip` 到所创建的全部虚拟环境。

`virtualenv` 是 `venv` 的第三方替代（及其前身）。 它允许在 Python 3.4 之前的版本中使用虚拟环境，那些版本或是完全不提供 `venv`，或是不会自动安装 pip 到所创建的虚拟环境。

#### 1.2.1. pip 基本命令
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

### 1.2.2. venv 基本命令

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

### 2.1. .gitignore文件中的忽略规则

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

### 2.2. 常用匹配示例：

`bin/` ：忽略当前路径下的bin文件夹，该文件夹下的所有内容都会被忽略，不忽略 bin 文件

`/bin` ：忽略根目录下的bin文件

`/*.c` ：忽略 cat.c，不忽略 build/cat.c

`debug/*.obj` ： 忽略 debug/io.obj，不忽略 debug/common/io.obj 和 tools/debug/io.obj

`**/foo` ： 忽略/foo, a/foo, a/b/foo等

`a/**/b` ： 忽略a/b, a/x/b, a/x/y/b等

`!/bin/run.sh` ： 不忽略 bin 目录下的 run.sh 文件

`*.log` ： 忽略所有 .log 文件

`config.php` ： 忽略当前路径的 config.php 文件

### 2.3. .gitignore 配置文件示例

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

## 流程控制工具——教程第3章

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
```py
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

##  数据结构——教程第五章

数据类型包含：
1. 序列
   序列分为 mutable 可变的 和 immutable 不可变的，包含：
   - list 列表，可变序列，用于存放同类项目的集合
   - tuple 元组，不可变序列，用于储存异构数据的多项集，或需要同类项目不可变
   - range 不可变数字序列，通常用于在 for 循环中循环指定的次数
   - str 字符串，文本序列，由 Unicode 码位构成
1. 集合 
   集合是由不重复元素组成的无序容器。基本用法包括成员检测、消除重复元素。集合对象支持合集、交集、差集、对称差分等数学运算。
   创建集合用花括号或 set() 函数。注意，创建空集合只能用 set()，不能用 {}，{} 创建的是空字典。
2. 字典


### list 列表详解
类似 `numpy.argmin()` 会返回下标，`list.index()` 可以返回列表中第一个值为 x 的元素的零基索引

#### 用列表实现堆栈很快，实现队列很慢
使用列表方法实现堆栈非常容易，最后插入的最先取出（“后进先出”）。把元素添加到堆栈的顶端，使用 `append()` 。从堆栈顶部取出元素，使用 `pop()` ，不用指定索引。

实现队列最好用 collections.deque，可以快速从两端添加或删除元素。

#### 列表推导式
创建平方值的列表：```squares = [x**2 for x in range(10)]```
等价于
```py
squares = []
for x in range(10):
    squares.append(x**2)
```

同样的：```combs = [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]```
等价于
```py
combs = []
for x in [1,2,3]:
    for y in [3,1,4]:
        if x != y:
            combs.append((x, y))
```

转置矩阵 ```matrix = [[1, 2, 3, 4],[5, 6, 7, 8],[9, 10, 11, 12]] ``` 的代码 ``` inversed = [[row[i] for row in matrix] for i in range(4)] ```
等价于
```py
for i in range(4):
    middle_var = []
    for row in matrix:
        middle_var.append(row[i])
    inversed.append(middle_var)

```

### tuple 元组详解
元组是不可变序列，在定义时使用逗号将多个值隔开，在没有嵌套的时候括号可用可不用（也就是没啥用）例如:
```py
player1 = 1, 'tank'
player2 = (2, 'dps')
team = player1, player2, (4, 'healer')
```
空元组可以用 `()` 表示，只有一个元素的元组**能且只能**在表达式结尾用 `,` 创建，例如：
```py
dead_tank = ()
dead_dps = 3, 
```

### set 集合详解
创建集合用花括号或 set() 函数。注意，创建空集合只能用 set()，不能用 {}，{} 创建的是空字典。
```
>>> a = set('banana')
...      
>>> a
...      
{'b', 'n', 'a'}
>>> b = set('pineapple')
...      
>>> b
...      
{'e', 'l', 'p', 'n', 'i', 'a'}
>>> a - b
...      
{'b'}
>>> a & b
...      
{'a', 'n'}
>>> a ^ b
...      
{'p', 'e', 'b', 'l', 'i'}
```

### dict 字典详解
与以连续整数为索引的序列不同，字典以**关键字**为索引，关键字通常是字符串或数字，也可以是其他任意不可变类型。只包含字符串、数字、元组的元组，也可以用作关键字。但如果元组直接或间接地包含了可变对象，就不能用作关键字。
创建字典的方法：
```
>>> tel = dict([('Alice', 4399), ('Bob', 7010), ('Clary', 7171)])
...      
>>> squr = {x: x**2 for x in (2,4,6)}
...      
>>> tel = dict(Xiaoming=110, Xiaohong=114, Xiaoliang=119)
```