from sklearn.impute import KNNImputer

import pandas as pd

import os
from pathlib import Path
import json

from sklearn.preprocessing import MinMaxScaler

pd.options.mode.chained_assignment = None
pd.set_option('future.no_silent_downcasting', True)

def run_imputation(filename: str, key_columns: list[str], non_covariate_columns: list[str], output_file: str) -> None:

    print("===== Pre-processing: Impute Missing Data =====")

    data = pd.read_csv(filename)

    # Step 1: Subset the data to just the id and covariates, dropping duplicates
    subset_data = data[key_columns].drop_duplicates()
    print("\tComplete: Subset and de-duplication")

    # Step 2: Convert sex to a binary variable for imputation
    subset_data['sex'] = subset_data['sex'].replace(['F', 'M'], [0, 1])
    print("\tComplete: Converting sex to binary values")

    # Step 3: Subset the data that has no missingness to test values of k
    non_id_columns = [x for x in key_columns if x != 'id']

    # NOTE: This is hard-coded after analysis completed in `preprocessing\3b_test_knn.py`
    k = 15
    
    # Step 4: Using the tested value of k, impute missing data
    imputer = KNNImputer(n_neighbors=k, add_indicator=True)
    covariate_data = subset_data[non_id_columns]
    scaler = MinMaxScaler()
    data_to_be_imputed = pd.DataFrame(
        scaler.fit_transform(covariate_data),
        columns=non_id_columns
    )
    imputed_data = imputer.fit_transform(data_to_be_imputed)
    imputed_df = pd.DataFrame(data = imputed_data, columns=non_id_columns + ["is_imputed_bmi", "is_imputed_pack_years", "is_imputed_units", "is_imputed_qualification"])
    print("\tComplete: Imputing missing data")

    # Step 5: Output resulting data
    ids = subset_data["id"].drop_duplicates().reset_index()
    imputed_df["id"] = ids["id"]

    data = data[non_covariate_columns]
    complete_data = data.merge(imputed_df, how="inner", on="id")
    
    output_file = os.path.join(Path.cwd(), output_file).replace("\\","/")
    complete_data.to_csv(output_file, index=False)  

if __name__ == "__main__":

    with open(os.path.join(Path.cwd(), "config.json").replace("\\","/")) as f:
        config = json.load(f)

    filename = os.path.join(Path.cwd(), config["data_sources"]["included_data"]).replace("\\","/")

    run_imputation(
        filename=filename, 
        key_columns=config["imputed_data"]["key_columns"],
        non_covariate_columns=config["imputed_data"]["non_covariate_columns"],
        output_file=config["data_sources"]["imputed_data"]
    )