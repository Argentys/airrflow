#!/usr/bin/env python3

import gzip
import pandas as pd
import sys
import json
import os
import requests
from io import StringIO, BytesIO

# Function to check if input is a URL
def is_url(input_string):
    return input_string.startswith(('http://', 'https://'))

# Read input from file or URL
input_arg = sys.argv[1]
if is_url(input_arg):
    # Download URL content
    response = requests.get(input_arg)
    response.raise_for_status()  # Raise exception for bad status codes
    
    # Handle gzip content if URL returns gzip
    if response.headers.get('Content-Encoding') == 'gzip':
        # Decompress gzip content
        content = gzip.decompress(response.content)
        # Convert bytes to string for JSON and CSV processing
        json_string = content.decode('utf-8').split('\n')[0].strip()
        # Create StringIO object for pandas to read CSV
        csv_content = StringIO(content.decode('utf-8').split('\n', 1)[1])
    else:
        # Handle non-gzip content
        content = response.text
        json_string = content.split('\n')[0].strip()
        csv_content = StringIO('\n'.join(content.split('\n')[1:]))
    
    df = pd.read_csv(csv_content)
else:
    # Original file-based input handling
    with gzip.open(input_arg, 'rt') as f:
        json_string = f.readline().strip()
        df = pd.read_csv(f)

# Process dataframe
df = df.rename(columns={col: col.replace('_heavy', '') for col in df.columns if col.endswith('_heavy')})
if "sequence_id" not in df.columns:
    df['sequence_id'] = range(1, len(df) + 1)

# Write output
df.to_csv(sys.argv[2], sep='\t', index=False)