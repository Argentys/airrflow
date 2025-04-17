#!/usr/bin/python3

import gzip
import pandas as pd
import sys
import json
import os

# Read from the gzip file
with gzip.open(sys.argv[1], 'rt') as f:
    json_string = f.readline().strip()  # Read the first line and strip whitespace
    df = pd.read_csv(f)

# Fix doubled quotes and remove outer quotes
json_string = json_string.replace('""', '"')  # Fix doubled quotes if present
if json_string.startswith('"') and json_string.endswith('"'):
    json_string = json_string[1:-1]  # Remove outer quotation marks

# Parse JSON with error handling
data = json.loads(json_string)
#for key in data:
#  print(f"{key}: {data[key]}")

df = df.rename(columns={col: col.replace('_heavy', '') for col in df.columns if col.endswith('_heavy')})

# Add sequence_id if not present
if "sequence_id" not in df.columns:
    df['sequence_id'] = range(1, len(df) + 1)

# Save to TSV
nm= sys.argv[2]
import shutil
shutil.rmtree(nm, ignore_errors=True)
os.mkdir(nm)
df.to_csv(nm + "/data.tsv", sep='\t', index=False)

ff = open(nm + "/input.tsv","w")
bt = data['BType']
bt = bt.replace("/","_")
species = data['Species']
if 'mouse' in species:
    species = 'mouse'
subject = data['Subject']
subject = subject.replace("/","_")
defline = f"filename\tspecies\tsubject_id\tsample_id\ttissue\tsex\tage\tbiomaterial_provider\tpcr_target_locus\tsingle_cell";
meta = f"data.tsv\t{species}\t{subject}\t{bt}\t{data['BSource']}\tmale\t{data['Age']}\t{data['Author']}\tIG\tFALSE"
print(defline, file = ff)
print(meta, file = ff)
ff.close()
