# G E T _ S T R U C T U R E S 

Given a fasta file and a target search database, fetches the best protein structure hits according to the filtering criteria. 

default filtering parameters: 
  - covmode_mmseqs = 2 ( coverage is computed on the query sequence ) 
  - min_id_filter = 0.99
  - min_cov_filter= 1.0
  

```
nextflow -bg run main.nf -profile crg,phylo3d
```
