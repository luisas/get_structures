#!/usr/bin/env python3

import pandas as pd
import sys

hits=sys.argv[1]
output=sys.argv[2]
template=sys.argv[3]
output_ids=sys.argv[4]
output_chains=sys.argv[5]
min_id = float(sys.argv[6])
min_cov = float(sys.argv[7])


def get_best_hits(hits, names):
    # Define custom aggregation functions
    agg_funcs = {
        'fident': 'max',
        'evalue': 'min',
        'qcov': 'max',
        'tcov': 'max',
        'qseq': 'first',
        'tseq': 'first'
    }

    # Read the CSV file with specified column names
    df = pd.read_csv(hits, sep='\t', header=None, names=names)

    # Group by the 'query' column and apply custom aggregation functions using transform
    df['identity_max'] = df.groupby('query')['fident'].transform('max')
    df['evalue_min'] = df.groupby('query')['evalue'].transform('min')
    df['coverage_max'] = df.groupby('query')['qcov'].transform('max')
    df['target_coverage'] = df.groupby('query')['tcov'].transform('max')
    df['first_qseq'] = df.groupby('query')['qseq'].transform('first')
    df['first_tseq'] = df.groupby('query')['tseq'].transform('first')

    # Drop duplicate rows to keep only unique 'query' values
    df.drop_duplicates(subset='query', inplace=True)

    # Reset the index
    df.reset_index(drop=True, inplace=True)

    # Add filter of coverage and identity
    df = df[df["fident"] >= min_id]
    df = df[df["qcov"] >= min_cov]

    return(df)

def main():
    df = get_best_hits(hits, names  = ["query", "target", "fident", "alnlen", "mismatch", "qseq", "tseq", "qend", "tstart", "tend", "evalue", "bits", "qcov", "tcov"])
    df.to_csv(output, sep="\t", header=None, index=False)

    # Create file with IDs to download
    df["target"].drop_duplicates().to_csv(output_ids, sep="\t", header=None, index=False)

    # Create template file
    df["sep"] = "_P_"
    df["query_id"]=">"+df["query"]
    df["target_id"] = df["target"]
    cols =  ["query_id","sep","target_id"]
    df[cols].to_csv(template, sep=" ", header=None, index=False)

if __name__ == "__main__":
    main()