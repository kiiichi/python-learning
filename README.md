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
 
**map(function, iterable, ...)**
 
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