import pandas as pd
import numpy as np
import json
import os
from pathlib import Path

IS_HEALTHY = "is_healthy"
FOLLOWUP_WINDOW = 10

def check_column_subset(data: pd.DataFrame, columns: list[str], new_column: str) -> pd.DataFrame:
    
    data[new_column] = ~data[columns].eq(1).any(axis=1)
    return data[["id", new_column]]

def check_counted_column(data: pd.DataFrame, column: str, new_column: str) -> pd.DataFrame:

    data[new_column] = data[column] == 0
    return data[["id", new_column]]

def convert_ym_columns(data: pd.DataFrame, column: str) -> pd.Series:
    data["temp_convert"] = data[column].astype("str").str[:4]
    data["temp_convert"] = data["temp_convert"].replace('nan', np.nan)
    data["temp_convert"] = data["temp_convert"].astype("Int64")

    return data["temp_convert"]

def remap_disease(data: pd.DataFrame, disease_list: list[str], map_target_column: str, map: dict[str, list[str]]) -> pd.DataFrame:

    data = data.replace({
        map_target_column: map
    })

    # Null any disease that isn't in the target mapping
    data.loc[~data[map_target_column].isin(disease_list), map_target_column] = np.nan
    data = data.drop_duplicates()

    return data

def self_reported_disease(data: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    subset_data = data[["id"] + columns]
    assigned_data = check_column_subset(subset_data, columns, "def1_" + IS_HEALTHY)

    assigned_data = assigned_data[["id", "def1_" + IS_HEALTHY]].drop_duplicates()

    return assigned_data

def ehr_prevalent(data: pd.DataFrame) -> pd.DataFrame:

    subset_data = data[["id", "disease", "incident"]]

    # If the EHR record is after the GS collection, we want to null out that data
    subset_data["disease"] = np.where(subset_data["incident"] == 1, np.nan, subset_data["disease"])
    subset_data["incident"] = subset_data["incident"].replace(1, np.nan)
    subset_data.drop_duplicates()

    # Aggregate by id
    subset_data["disease"] = subset_data["disease"].replace(np.nan, "")
    subset_data["disease_coding"] = subset_data["disease"].apply(lambda x: 1 if x != "" else 0)
    grouped_data = subset_data[["id", "disease_coding"]].groupby(by="id", as_index = False)["disease_coding"].sum()

    return check_counted_column(grouped_data, "disease_coding", "def2_is_healthy")

def ehr_incident_followup(data: pd.DataFrame) -> pd.DataFrame:

    subset_data = data[["id", "disease", "incident", "dt1_ym", "gs_appt"]]

    # If the EHR record is before the GS collection, we want to null out that data
    subset_data["disease"] = np.where(subset_data["incident"] == 0, np.nan, subset_data["disease"])
    subset_data["incident"] = subset_data["incident"].replace(0, np.nan)

    # If the EHR record is after the follow-up window, we want to null out that data
    subset_data["appt_y"] = convert_ym_columns(subset_data, "dt1_ym")
    subset_data["gs_appt_y"] = convert_ym_columns(subset_data, "gs_appt")
    subset_data["time_between_appts"] = subset_data["appt_y"] - subset_data["gs_appt_y"]

    m1 = subset_data["time_between_appts"] > FOLLOWUP_WINDOW
    m2 = subset_data["time_between_appts"] < 0
    subset_data["disease"].loc[m1] = None
    subset_data["disease"].loc[m2] = None
    subset_data.drop_duplicates()

    # Aggregate by id
    subset_data["disease"] = subset_data["disease"].replace(np.nan, "")
    subset_data["disease_coding"] = subset_data["disease"].apply(lambda x: 1 if x != "" else 0)
    grouped_data = subset_data[["id", "disease_coding"]].groupby(by="id", as_index = False)["disease_coding"].sum()

    return check_counted_column(grouped_data, "disease_coding", "def3_is_healthy")


def run_definition_assignment(filename: str, output_file: str) -> None:

    data = pd.read_csv(filename)

    definition1 = self_reported_disease(data, ["heart_disease_y", "stroke_y", "high_bp_y", "diabetes_y", "alzheimers_y", "parkinsons_y", "depression_y", "breast_cancer_y", "bowel_cancer_y", "lung_cancer_y", "prostate_cancer_y", "hip_fracture_y", "osteo_arthritis_y", "rheum_arthritis_y", "asthma_y", "copd_y"])
    print("Definition 1: num_healthy", definition1[definition1["def1_is_healthy"] == 1].count())
    print("Definition 1: not num_healthy", definition1[definition1["def1_is_healthy"] == 0].count())
    
    definition2 = ehr_prevalent(data)
    print("Definition 2: num_healthy", definition2[definition2["def2_is_healthy"] == 1].count())
    print("Definition 2: not num_healthy", definition2[definition2["def2_is_healthy"] == 0].count())

    definition3 = ehr_incident_followup(data)
    print("Definition 3: num_healthy", definition3[definition3["def3_is_healthy"] == 1].count())
    print("Definition 3: not num_healthy", definition3[definition3["def3_is_healthy"] == 0].count())

    merged_classifications = definition1.merge(definition2.merge(definition3, on="id", how="inner"), on="id", how="inner")
    
    output_file = os.path.join(Path.cwd(), output_file).replace("\\","/")
    merged_classifications.to_csv(output_file, index=False)
    

if __name__ == "__main__":

    with open(os.path.join(Path.cwd(), "config.json").replace("\\","/")) as f:
        config = json.load(f)

    filename = os.path.join(Path.cwd(), config["data_sources"]["imputed_data"]).replace("\\","/")

    run_definition_assignment(
        filename=filename,
        output_file=config["data_sources"]["classification_data"]
    )