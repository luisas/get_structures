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
header = sys.argv[8]


def fident(s1, s2):
    if(len(s1) != len(s2)):
        raise Exception("Strings must be of equal length")
    matches = 0
    for i in range(len(s1)):
        if s1[i] == s2[i]:
            matches += 1
    return matches/len(s1)

# cut the sequence given first and last residue
def cut_sequence(sequence, first_residue, last_residue):
    first_residue = first_residue - 1 # to match with the index of the sequence
    last_residue = last_residue - 1
    return sequence[first_residue:last_residue+1]

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


    # Remove hits with gaps 
    df = df[df.gapopen == 0]

    # Remove hits with different length
    df["qcut"] = df.apply(lambda x: cut_sequence(x["qseq"], x["qstart"], x["qend"]), axis=1)
    df["tcut"] = df.apply(lambda x: cut_sequence(x["tseq"], x["tstart"], x["tend"]), axis=1)
    df["qcut_len"] = df.apply(lambda x: len(x["qcut"]), axis=1)
    df["tcut_len"] = df.apply(lambda x: len(x["tcut"]), axis=1)
    df["qseq_len"] = df.apply(lambda x: len(x["qseq"]), axis=1)
    df["tseq_len"] = df.apply(lambda x: len(x["tseq"]), axis=1)
    df = df[df["qcut_len"] == df["tcut_len"]]

    # Recompute fident 
    df["fident"] = df.apply(lambda x: fident(x["qcut"], x["tcut"]), axis=1)

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

    # Remove columns that are not needed anymore
    df.drop(columns=['identity_max', 'evalue_min', 'coverage_max', 'target_coverage', 'first_qseq', 'first_tseq'], inplace=True)
    
    return(df)

def main():
    df = get_best_hits(hits, names  = header.split(","))
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