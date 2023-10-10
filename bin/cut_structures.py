#!/usr/bin/env python3

import pandas as pd
import sys
import csv

hits = sys.argv[1]
header = sys.argv[2]
# Extract the indeces of start and end of the cut (qstart and qend) from the header of the search results
index_start_cut = header.split(",").index("tstart")
index_end_cut = header.split(",").index("tend")

hits_df = pd.read_csv(hits, sep = "\t", header = None)
hits_df["name"] = hits_df[0].str.replace("/", "_")
hits_df =hits_df.rename(columns = {index_start_cut:"start_cut", index_end_cut: "end_cut"})
hits_df["line"] = hits_df.apply(lambda row : "extract_structure.py "+row["name"]+".pdb "+str(row["start_cut"])+" "+str(row["end_cut"])+" "+(row["name"]), axis=1)
hits_df["line"].to_csv("cut_structures_tmp.sh", sep=" ", header=None, index=False, quoting=csv.QUOTE_NONE, escapechar=",")