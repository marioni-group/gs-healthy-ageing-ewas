library(data.table)
library(IlluminaHumanMethylationEPICanno.ilm10b4.hg19)
library(missMethyl)
library(jsonlite)

config <- fromJSON(file.path(getwd(), "config.json"))

# Retrieve significant CpGs and all CpGs
EWAS_RESULTS_PATH = config$analysis_config$ewas_results_path

input_file <- paste(
  c( 
    EWAS_RESULTS_PATH,
    "_bonferroni_significant_hits.csv"
  ),
  collapse=""
)
all_cpg_file_name <- paste(
  c(
    EWAS_RESULTS_PATH,
    "_all_cpgs.csv"
  ),
  collapse=""
)

data <- fread(input_file)
data <- subset(data, select = c(Probe, b, se, p, fdr))
all_cpg <- fread(all_cpg_file_name)
all_cpg <- subset(all_cpg, select = c(Probe, b, se, p, fdr))

# Run pathway enrichment
kegg_results <- gometh(
  data$Probe,
  all.cpg = all_cpg$Probe,
  collection = "KEGG",
  array.type = "EPIC",
  prior.prob = TRUE,
  fract.counts = TRUE,
  sig.genes = TRUE
)

# Retrieve the pathway ids for the output
kegg_ids <- rownames(kegg_results)
rownames(kegg_results) <- kegg_ids

# Output the results
output_pathway_file <- paste(
  c(
    EWAS_RESULTS_PATH,
    "_kegg_results.csv"
  ),
  collapse=""
)
write.csv(kegg_results, output_pathway_file, row.names=TRUE)
