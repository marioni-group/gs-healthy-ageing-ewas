library(jsonlite)

config <- fromJSON(file.path(getwd(), "config.json"))

EWAS_CATALOG_FOLDER <- config$ewas_catalog_config$ewas_catalog_folder

# Import study data from EWAS Catalog
studies <- read.table(paste0(c(EWAS_CATALOG_FOLDER, "/studies.txt")), header=TRUE, sep = "\t", quote="\n")
studies <- studies[c("n", "pmid", "trait", "exposure", "methylation_array", "tissue", "ethnicity", "study_id", "sex")]

# Subset the studies by applicable fields
studies <- studies[studies$sex == "Both",]
studies <- studies[studies$ethnicity == "European",]
studies <- studies[!studies$methylation_array %in% c("Bisulfite pyrosequencing", "MALDI-TOF mass spectrometry"),]
studies <- studies[studies$tissue %in% c(
    "Whole blood", 
    "Whole Blood", 
    "Whole blood and CD4+ T cells", 
    "Whole blood and cord blood", 
    "whole blood", 
    "Whole Blood, Monocytes", 
    "Whole blood, CD4+ T-cells, CD14+ monocytes", 
    "Whole blood, heel prick blood spots", 
    "blood"
    ),
]
studies$n_int = as.numeric(studies$n)
studies <- studies[studies$n_int >= 1000,]

# Remove duplicate studies
studies <- studies[!duplicated(studies), ]

# Import result data from EWAS Catalog
results <- read.table(paste0(c(EWAS_CATALOG_FOLDER, "/results.txt")), header=TRUE, sep = "\t", quote="\n")
results <- results[c("cpg", "study_id", "gene", "beta")]

# Merge study and result data
output_table <- merge(studies, results, on="study_id")
output_table <- output_table[c("cpg", "pmid", "trait", "exposure", "gene", "beta")]
output_table$catalog_beta = output_table$beta

# Remove duplicate results
output_table <- output_table[!duplicated(output_table), ]

# Export the results
write.csv(output_table, paste0(c(EWAS_CATALOG_FOLDER, "/subset_catalog.csv")),  row.names = FALSE)
