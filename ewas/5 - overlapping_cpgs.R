library(ggvenn)
library(ggplot2)
library(jsonlite)
source("helpers.R")

config <- fromJSON(file.path(getwd(), "config.json"))

# Retrieve significant results across all definitions for a given covariate set

EWAS_PATH = config$analysis_config$ewas_path
EWAS_COVARIATE_SET = onfig$analysis_config$ewas_covariate_set

EWAS_FILES <- list(
  def1 = paste0(c(EWAS_PATH, "/def1/", EWAS_COVARIATE_SET, "/", EWAS_COVARIATE_SET, "_bonferroni_significant_hits.csv")),
  def2 = paste0(c(EWAS_PATH, "/def2/", EWAS_COVARIATE_SET, "/", EWAS_COVARIATE_SET, "_bonferroni_significant_hits.csv")),
  def3 = paste0(c(EWAS_PATH, "/def3/", EWAS_COVARIATE_SET, "/", EWAS_COVARIATE_SET, "_bonferroni_significant_hits.csv")),
)
OUTPUT <- EWAS_PATH

# Step 1: Generate list of CpGs that are in 2 or more definition results
hits <- lapply(names(EWAS_FILES), function(def) {
  dat <- read.csv(EWAS_FILES[[def]])
  dat <- dat[, c("Probe", "b", "p")]
  colnames(dat)[2:3] <- paste0(c("b_", "p_"), def)
  dat
})
names(hits) <- names(EWAS_FILES)
all_cpgs <- table(unlist(lapply(hits, function(x) x$Probe)))
cpgs_in_2plus <- names(all_cpgs[all_cpgs >= 2])

merged <- Reduce(function(a, b) merge(a, b, by = "Probe", all = TRUE), hits)
merged <- merged[merged$Probe %in% cpgs_in_2plus, ]
merged <- merged[order(rowSums(!is.na(merged)), decreasing = TRUE), ]

write.csv(merged, paste0(OUTPUT, EWAS_COVARIATE_SET, "_cpg_overlap_2plus_definitions.csv"), row.names = FALSE)

# Step 2: Generate venn diagram of CpGs
def1 <- hits$def1$Probe
def2 <- hits$def2$Probe
def3 <- hits$def3$Probe

all_cpgs <- list(
  "Self-Report Prevalence" = def1,
  "EHR-Report Prevalence" = def2,
  "EHR-Report Incidence" = def3
)

fig <- ggvenn(
  all_cpgs,
  fill_color = c(PRIMARY, SECONDARY, TERTIARY),
  fill_alpha = 0.8,
  set_name_size = 5,
  text_size = 4,
  show_percentage = FALSE
) +
  labs(title = "Bonferroni Significant CpG Overlap — Cell-Adjusted") +
  theme(plot.title = element_text(hjust = 0.5, size = 20))

ggsave(paste0(OUTPUT, EWAS_COVARIATE_SET, "_venn.png"), plot = fig, width = 8, height = 8, dpi = 300)
