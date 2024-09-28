#!/usr/bin/python3
import pandas as pd
import sys

df = pd.read_csv(sys.argv[1], delimiter='\t')
for index, row in df.iterrows():
        print(f"Row {index + 1}:")
        for col in df.columns:
            print(f"{col}: {row[col]}")
