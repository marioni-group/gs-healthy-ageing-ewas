import pandas as pd
import numpy as np
import os
import json

def clean_table(data: pd.DataFrame, config: object) -> pd.DataFrame:

    column_mapping = config["column_mapping"]
    drop_columns = config["drop_columns"]
    convert_columns = config["convert_columns"]
    convert_type = config["convert_type"]

    # Convert all column names to lower case
    data.columns = data.columns.str.lower()

    # Rename any columns set up in the config
    if column_mapping != {}:
        data = data.rename(columns = column_mapping)

    # Drop any columns that aren't required
    if drop_columns != []:
        data = data.drop(columns=drop_columns)

    # Convert any types required
    if convert_columns != []:
        data[convert_columns] = data[convert_columns].astype(convert_type)

    return data


def run_preprocessing(data_sources: object, selected_diseases: list[str]) -> None:
    print("===== Pre-processing: Clean and Merge =====")

    # Step 1: Read in the files
    self_reported_data = pd.read_csv(data_sources["self_reported"]["file_path"])
    ehr_records_data = pd.read_csv(data_sources["ehr_records"]["file_path"])
    covariates_data = pd.read_csv(data_sources["covariates"]["file_path"])
    deaths_data = pd.read_csv(data_sources["deaths"]["file_path"])
    disease_names = pd.read_table(data_sources["disease_names"]["file_path"], sep="\t")
    print("\tComplete: Reading data sources")

    # Step 2: Clean up each dataframe as required
    self_reported_data = self_reported_data.replace(np.nan, 0)
    self_reported_data = clean_table(self_reported_data, data_sources["self_reported"])
    ehr_records_data = clean_table(ehr_records_data, data_sources["ehr_records"])
    covariates_data = clean_table(covariates_data, data_sources["covariates"])
    deaths_data = clean_table(deaths_data, data_sources["deaths"])
    disease_names = clean_table(disease_names, data_sources["disease_names"])
    print("\tComplete: Cleaning source tables")

    # Step 3: Merge the EHR records and Disease names, then only keep the diseases
    # that are in the selected_disease list
    ehr_disease_names = pd.merge(ehr_records_data, disease_names, on="disease")

    ehr_disease_names = ehr_disease_names[ehr_disease_names["phenotype"].isin(selected_diseases)]
    print("\tComplete: Merging EHR records and disease names")

    # Step 4: Left join the remaining datasets
    all_diseases = self_reported_data.merge(ehr_disease_names, on="id", how="left")
    all_disease_death = all_diseases.merge(deaths_data, on="id", how="left")
    all_data = all_disease_death.merge(covariates_data, on="id", how="left")
    print("\tComplete: Merging all data sources")

    # Step 5: Export cleaned and merged data
    output_file = os.path.join(os.getcwd(), data_sources["merged_data"]).replace("\\","/")
    all_data.to_csv(output_file, index=False)
    print("\tComplete: Exporting merged data", output_file)



if __name__ == "__main__":
    with open(os.path.join(os.getcwd(), "config.json").replace("\\","/")) as file:
        config = json.load(file)

    run_preprocessing(config["data_sources"], config["selected_diseases"])