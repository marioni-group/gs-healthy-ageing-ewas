library(org.Hs.eg.db)
library(AnnotationDbi)
library(jsonlite)

config <- fromJSON(file.path(getwd(), "config.json"))

# Read in all relevant data files
EWAS_PATH = config$analysis_config$ewas_path
EWAS_COVARIATE_SET = onfig$analysis_config$ewas_covariate_set
EWAS <- paste0(c(EWAS_PATH, "/", EWAS_COVARIATE_SET, "_cpg_overlap_2plus_definitions.csv"))
EWAS_CATALOG_FOLDER = config$ewas_catalog_config$ewas_catalog_folder

ewas <- read.csv(EWAS)
ewas_catalog <- read.csv(paste0(c(EWAS_CATALOG_FOLDER, "subset_catalogcsv")))

# Subset the EWAS Catalog to CpGs in the overlap dataset
catalog_hits <- ewas_catalog[ewas_catalog$cpg %in% ewas$Probe,]

# For all hits between the EWAS and the Catalog, merge the data sources
if (nrow(catalog_hits) > 0) {
  
  # Count hits per trait
  trait_counts <- as.data.frame(table(catalog_hits$trait))
  colnames(trait_counts) <- c("trait", "n_cpgs")
  trait_counts <- trait_counts[order(trait_counts$n_cpgs, decreasing = TRUE), ]
  
  # Count hits per CpG
  cpg_counts <- as.data.frame(table(catalog_hits$cpg))
  colnames(cpg_counts) <- c("cpg", "n_traits")
  cpg_counts <- cpg_counts[order(cpg_counts$n_traits, decreasing = TRUE), ]

  # Add direction for EWAS and Catalog
  trait_name_direction <- catalog_annotated[, c("trait", "cpg", "b_def1", "b_def2", "b_def3")]
  
  traits <- as.character(trait_counts$trait)
  
  # Merge all data
  catalog_annotated <- merge(
    catalog_hits,
    ewas,
    by.x="cpg",
    by.y="Probe",
    all.x = TRUE
  )
  
  # Export the results
  write.csv(catalog_hits, paste0(EWAS_PATH, EWAS_COVARIATE_SET, "_catalog_hits.csv"),  row.names = FALSE)
  write.csv(trait_counts, paste0(EWAS_PATH, EWAS_COVARIATE_SET, "_trait_counts.csv"),  row.names = FALSE)
  write.csv(cpg_counts, paste0(EWAS_PATH, EWAS_COVARIATE_SET, "_cpg_trait_counts.csv"), row.names = FALSE)
  write.csv(trait_name_direction, paste0(EWAS_PATH, EWAS_COVARIATE_SET, "_trait_name_direction.csv"), row.names=FALSE)

}
