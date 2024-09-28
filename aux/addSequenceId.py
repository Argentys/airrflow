#!/usr/bin/python3
import pandas as pd
import sys


import gzip
with gzip.open(sys.argv[1], 'rt') as f:
    first_line = f.readline().strip()  # Read the first line and strip whitespace
    print("First line:", first_line)  # Print the first line
    df = pd.read_csv(f)

if "sequence_id" not in df.columns:
   df['sequence_id'] = range(1, len(df) + 1)
nm = sys.argv[1].split(".")[0] + ".tsv"
df.to_csv(nm, sep='\t', index=False)
