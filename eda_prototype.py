"""
Prototype of Exploratory Data Analysis
"""

import pandas as pd
import numpy as np
import networkx as nx

# Read raw file
raw_df = pd.read_csv('./Data/crx.data', header=None)
raw_df.columns = [str(col) for col in raw_df.columns]   # String the variable names

# Data cleansing
raw_df['1'] = raw_df['1'].map(lambda val: np.nan if val == '?' else float(val))

print('Source data preview:')
print(raw_df.head())
print('Rows: {}, Columns: {}'.format(raw_df.shape[0], raw_df.shape[1]))

# Cardinality per variable
cardinality_df = pd.DataFrame([{'variable': col, 'nunique_raw': int(raw_df[col].nunique())} for col in raw_df.columns])

# Discretise numerical features
q_range = np.arange(0, 1.1, 0.1).tolist()

num_col_ls = list(raw_df.select_dtypes(include=['number']).columns)
dscrt_df = pd.concat([pd.qcut(raw_df[col], q=q_range, duplicates='drop') if col in num_col_ls else raw_df[col] for col in raw_df.columns], axis=1)
dscrt_df['key'] = dscrt_df.apply(lambda x: str([str(val) for val in x]), axis=1)
print(dscrt_df.head())

cardinality_df['nunique_dscr'] = [int(dscrt_df[col].nunique()) for col in dscrt_df.columns if col != 'key']

dscrt_keys_df = dscrt_df.groupby(['key']).count()

print(dscrt_keys_df)

# Discretise categorical features
# Each categorical variable with high cardinality > 10 to be mean encoded

