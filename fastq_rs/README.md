# nf_playground - fastq-rs

## Requirements
```
docker
nextflow
```

## Usage
Build docker images (locally) with

```bash
make
```

Test workflow with
```bash
nextflow run main.nf --input_tsv ./test_data/test.tsv --outdir test_run -profile "16s_nanopore_hac"
```
