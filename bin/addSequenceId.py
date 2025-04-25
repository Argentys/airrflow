#!/usr/bin/python3

import gzip
import pandas as pd
import sys
import json
import os

with gzip.open(sys.argv[1], 'rt') as f:
    json_string = f.readline().strip()  # Read the first line and strip whitespace
    df = pd.read_csv(f)

json_string = json_string.replace('""', '"')  # Fix doubled quotes if present
if json_string.startswith('"') and json_string.endswith('"'):
    json_string = json_string[1:-1]  # Remove outer quotation marks

data = json.loads(json_string)
#for key in data:
#  print(f"{key}: {data[key]}")

df = df.rename(columns={col: col.replace('_heavy', '') for col in df.columns if col.endswith('_heavy')})

# Add sequence_id if not present
if "sequence_id" not in df.columns:
    df['sequence_id'] = range(1, len(df) + 1)

df.to_csv(sys.argv[2], sep='\t', index=False)
