library(tidyverse)
library(dplyr)
library(jsonlite)

config <- fromJSON(file.path(getwd(), "config.json"))

# Merge the phenotypes with the DNAm data to get the correct ids and the cell composition data
classifications <- read_csv(config$data_sources$classifications)

dnam_data <- readRDS(file.path(getwd(), config$data_sources$cell_composition))
dnam_cols = c("Sample_Name", "Sample_Sentrix_ID", "Bcell", "CD4T", "CD8T", "Mono", "Neu", "NK")
dnam_data <- dnam_data[dnam_cols]

# Rename the id and merge the data frames on Sample Name
classifications = rename(classifications, Sample_Name = id)
merged_data <- merge(classifications, dnam_data, by="Sample_Name")

# Merge the data for the smoking probe to regress out
excluded_probe <- read.delim(file.path(getwd(), config$data_sources$smoking_probe), header=TRUE, sep=" ")
excluded_probe <- rename(excluded_probe, Sample_Name = IID)
merged_data <- merge(merged_data, excluded_probe, by="Sample_Name")

# Merge the ids and phenotypes with the covariate data
cov_cols = c("id", "age", "sex", "bmi", "pack_years", "units", "years", "is_imputed_bmi", "is_imputed_pack_years",	"is_imputed_units", "is_imputed_qualification")
covariate_data <- read_csv(file.path(getwd(), config$data_sources$imputed_data))
covariate_data = covariate_data[cov_cols]
covariate_data <- distinct(covariate_data)

covariate_data = rename(covariate_data, Sample_Name = id)
merged_cov_data = merge(merged_data, covariate_data, by="Sample_Name")

# Export the resulting data
write.csv(merged_cov_data, file.path(getwd(), config$data_sources$ewas_prep_data))
