import numpy as np

# 假设有两个维度相同的列表
list1 = [1, 2, 3, 4, 5]
list2 = [6, 7, 8, 9, 10]

# 将列表转换为NumPy数组
array1 = np.array(list1)
array2 = np.array(list2)
split_size = len(array1) // 2
array1 = array1[:split_size*2]
print(array1)
