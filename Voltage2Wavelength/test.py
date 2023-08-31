import pandas as pd

# Sample DataFrame
df = pd.DataFrame({
    'A': [1, 2, 3],
    'B': [4, 5, 6],
    'C': [7, 8, 9]
})

# Convert DataFrame to NumPy array
arr = df.values
print(df)
print(arr[:,0])