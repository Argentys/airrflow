#!/usr/bin/env python3
 
import gzip
import pandas as pd
import sys
import json
import os

with gzip.open(sys.argv[1], 'rt') as f:
    json_string = f.readline().strip()  # Read the first line and strip whitespace
    df = pd.read_csv(f)
df = df.rename(columns={col: col.replace('_heavy', '') for col in df.columns if col.endswith('_heavy')})
if "sequence_id" not in df.columns:
    df['sequence_id'] = range(1, len(df) + 1)
df.to_csv(sys.argv[2], sep='\t', index=False)
