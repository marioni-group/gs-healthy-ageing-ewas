# Generation Scotland Healthy Ageing EWAS
EWAS and binary classification using the Generation Scotland data to evaluate healthy ageing definitions. There is a mixture of Python and R scripts.

## How to Run

For each section, the scripts are numbered in the order they need to be run in.

### Configuration

The scripts assume the existence of a `config.json` file in the root with paths to the following Generation Scotland files (`config.json.template` included to demonstrate the expected format):

1. EHR Diseases
2. Covariates
3. Self-Reported Diseases
4. Disease Phenotypes

The config should also contain the covariates for each script, as mentioned in the template file.

### Pre-processing

The first step to the analysis is to run the pre-processing scripts that will handle the raw data. This can be run using the following command:

```
python preprocessing/{script_name}
```

### EWAS

The R scripts capture the preparation and analysis code required to run the data. Each can be run using the following command:

```
R ewas/{script_name}
```

In between `2 - regress_covariates.R` and `3 - ewas_results.R` is running the OSCA EWAS as follows:

```
osca --linear \
     --befile {input_file} \
     --pheno {phenotype_file} \
     --fast-linear \
     --out {output_folder}
```

### Classification

TBD

### Analysis

TBD