# Generation Scotland Healthy Ageing EWAS
EWAS and binary classification using the Generation Scotland data to evaluate healthy ageing definitions.

## How to Run

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

TBD

### Classification

TBD

### Analysis
