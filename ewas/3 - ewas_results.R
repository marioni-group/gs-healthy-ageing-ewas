library(data.table)
library(ggplot2)
library(ggrepel)
library(jsonlite)
source("helpers.R")

config <- config <- fromJSON(file.path(getwd(), "config.json"))

PLOT_TITLE = "EWAS Manhattan Plot - Definition 1 Cell-Adjusted (excluding cg05575921)"
BASE_DIR = config$ewas_config$ewas_output_path

# All chromosomes were written as separate files and need to be merged together
ewas_files <- list.files(path=BASE_DIR, pattern="\\.linear$", full.names=TRUE)
ewas_list <- lapply(ewas_files, fread)
ewas <- rbindlist(ewas_list)

# Summary Statistics
cat("Min p", min(ewas$p))
cat("Median p", min(ewas$p))
cat("Max p", max(ewas$p))
cat("Beta range", min(ewas$b), max(ewas$b))

# Subsetting Bonferroni and FDR Significant Results
bonferroni_threshold <- 0.05 / nrow(ewas)
ewas$fdr <- p.adjust(ewas$p, method="fdr")

cat("Bonferroni threshold", bonferroni_threshold)
cat("Bonferroni adjusted significant probes", sum(ewas$p < bonferroni_threshold))
cat("FDR < 0.05", sum(ewas$fdr < 0.05))

fwrite(ewas[ewas$p < bonferroni_threshold], file.path(BASE_DIR, "bonferonni_significant_hits.csv", sep="_"))
fwrite(ewas[ewas$fdr < 0.05], file.path(BASE_DIR, "fdr_significant_hits.csv", sep="_"))

# Generate the Manhattan Plot from the signficant results
probe_mapping <- fread(config$ewas_config$probe_mapping)
ewas_mapping <- merge(ewas, probe_mapping, by="Probe")

# Drop any probes that can't be mapped to a chromosome
ewas_mapping <- ewas_mapping[!is.na(CHR) & !is.na(BP)]
ewas_mapping$CHR <- as.numeric(ewas_mapping$CHR)

# Sort and scale the data
setorder(ewas_mapping, CHR, BP)
ewas_mapping[, logP := -log10(p)]
chr_lengths <- ewas_mapping[, .(maxBP=max(BP)), by=CHR]
chr_lengths[, cumstart := cumsum(c(0, head(maxBP, -1)))]
ewas_mapping <- merge(ewas_mapping, chr_lengths[,.(CHR, cumstart)], by="CHR")
ewas_mapping[, BP_cum := BP + cumstart]

# Set the center for ease of reading
chr_centers <- ewas_mapping[, .(
  center = mean(BP_cum)
), by = CHR]

# Generate figure
png(paste(paste(BASE_DIR, MODEL_NAME, sep="/"), "manhattan_plot.png", sep="_"), width=1200, height=600)

ewas_mapping <- ewas_mapping[order(ewas_mapping$p), ]
top_per_chr <- !duplicated(ewas_mapping$CHR)
ewas_mapping$label <- ifelse(top_per_chr & ewas_mapping$p < bonferroni_threshold, ewas_mapping$Probe, NA)

ggplot(
  ewas_mapping,
  aes(x=BP_cum, y=-log10(p), colour = factor(CHR %% 2))) +
  geom_point(size=0.5, alpha=0.4) +
  geom_hline(yintercept=-log10(bonferroni_threshold), linetype = "dashed", linewidth=0.7, color="red") +
  geom_label_repel(aes(label = label),
                   na.rm        = TRUE,
                   size         = 3,
                   max.overlaps = 20,
                   box.padding  = 0.4,
                   colour       = PRIMARY,
                   fill         = "white") +
  scale_colour_manual(values = c("0" = PRIMARY, "1" = SECONDARY), guide = "none") +
  scale_x_continuous(
    breaks = chr_centers$center,
    labels = chr_centers$CHR
  ) +
  theme_bw() +
  theme(legend.position="none") +
  labs(
    x="Chromosome", 
    y="-log10(P)", 
    title=PLOT_TITLE
  )

dev.off()