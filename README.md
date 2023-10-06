# G E T _ S T R U C T U R E S 

Given a fasta file and a target search database, fetches the best protein structure hits according to the filtering criteria. 

default filtering parameters: 
  - min_id_mmseqs = 0.9
  - min_cov_mmseqs = 1
  - covmode_mmseqs = 2 ( coverage is computed on the query sequence ) 
  - min_id_filter = 1.0
  - min_cov_filter= 1.0
  
The mmseqs filters (min_id_mmseqs, min_cov_mmseqs, covmode_mmseqs) define the parameters with which the search is performed. 
The filter parameters define the the filters applied to the mmseqs results and the results of this filter define which structures will be eventually downloaded. The filtering parameters cannot be more permissive than the mmseqs ones. 
The reason behind this double filtering is that we may want to run the search once with more permissive filters first and experiment later with different filterings without the need of recomputing the search.


```
nextflow -bg run main.nf -profile crg,phylo3d
```
