global_variable = 10

def print_global():
    print("全局变量的值:", global_variable)

print_global()  # 输出 10

global_variable = 20

print_global()  # 输出 10，而不是 20