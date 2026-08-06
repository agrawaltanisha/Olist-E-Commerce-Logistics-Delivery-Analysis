import pandas as pd, glob, os

files = sorted(glob.glob("data/*.csv"))
print(f"Found {len(files)} CSV files\n")

for f in files:
    df = pd.read_csv(f)
    print(f"=== {os.path.basename(f)} | {df.shape[0]:,} rows x {df.shape[1]} cols")
    print(df.dtypes.to_string())
    nulls = df.isna().sum()
    print("nulls:", nulls[nulls > 0].to_dict())
    print()
