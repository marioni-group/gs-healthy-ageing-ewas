import pandas as pd
import numpy as np
import os
import json
from pathlib import Path

pd.options.mode.chained_assignment = None

def count_num_missing(data: pd.DataFrame, id_column: str, covariate_columns: list[str]) -> pd.Series:
    
    key_columns = [id_column] + covariate_columns
    subset_data = data[key_columns]
    subset_data["null_count"] = subset_data.isna().sum(axis=1)

    return subset_data["null_count"]


def run_exclusion_criteria(filename: str, key_covariates: list[str], output_file: str) -> None:
    print("===== Pre-processing: Exclusion Criteria =====")

    data = pd.read_csv(filename)

    # Step 1: Count the number of missing key covariates per id
    # Export the null counts and covariates to run an anlysis
    data["null_count"] = count_num_missing(data, "id", key_covariates)
    print("\tComplete: Counting null covariates")


    # Step 2: Drop data that is missing the majority of the key covariates (ie >= 4)
    data = data[data["null_count"] < 4]
    print("\tComplete: Dropping high missingness data")
    
    # Step 3: Export the results
    output_file = os.path.join(os.getcwd(), output_file).replace("\\","/")
    data.to_csv(output_file, index=False)
    print("\tComplete: Exporting included data")


if __name__ == "__main__":

    with open(os.path.join(Path.cwd(), "config.json").replace("\\","/")) as f:
        config = json.load(f)

    filename = os.path.join(Path.cwd(), config["data_sources"]["merged_data"]).replace("\\","/")
    run_exclusion_criteria(
        filename=filename, 
        key_covariates=config["exclusion_criteria"]["key_covariates"], 
        output_file=config["data_sources"]["included_data"],
    )