library(tidyverse)
library("GMMAT")
library(data.table)
library(jsonlite)

config <- fromJSON(file.path(getwd(), "config.json"))

kinship <- readRDS(file.path(getwd(), config$data_sources$kinship))
data <- read_csv(file.path(getwd(), config$data_sources$ewas_prep_data))

#------------------------------#
# Definition 1 (Self-Reported) #
#------------------------------#

# Minimal Set (Age and Sex only)
model_def1_1 = glmmkin(
  def1_is_healthy ~ age + sex + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def1_1)

def1_1_output <- select(data, c("Sample_Name"))
def1_1_output$ID2 <- data$Sample_Name
def1_1_output$residual <- as.numeric(r)

fwrite(def1_1_output, file.path(getwd(), config$data_sources$def1_m1_output) sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)

# Cell-Adjusted Set
model_def1_2 = glmmkin(
  def1_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family=binomial(link="logit")
)

r <- resid(model_def1_2)

def1_2_output <- select(data, c("Sample_Name"))
def1_2_output$ID2 <- data$Sample_Name
def1_2_output$residual <- as.numeric(r)

fwrite(def1_2_output, file.path(getwd(), config$data_sources$def1_m2_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)


# Full Set
model_def1_3 = glmmkin(
  def1_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + bmi + pack_years + units + years + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def1_3)

def1_3_output <- select(data, c("Sample_Name"))
def1_3_output$ID2 <- data$Sample_Name
def1_3_output$residual <- as.numeric(r)

fwrite(def1_3_output, file.path(getwd(), config$data_sources$def1_m3_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)

#-------------------------------#
# Definition 2 (EHR Prevalence) #
#-------------------------------#

# Minimal Set (Age and Sex only)
model_def2_1 = glmmkin(
  def2_is_healthy ~ age + sex + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def2_1)

def2_1_output <- select(data, c("Sample_Name"))
def2_1_output$ID2 <- data$Sample_Name
def2_1_output$residual <- as.numeric(r)

fwrite(def2_1_output, file.path(getwd(), config$data_sources$def2_m1_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)


# Cell-Adjusted Set
model_def2_2 = glmmkin(
  def2_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family=binomial(link="logit")
)

r <- resid(model_def2_2)

def2_2_output <- select(data, c("Sample_Name"))
def2_2_output$ID2 <- data$Sample_Name
def2_2_output$residual <- as.numeric(r)

fwrite(def2_2_output, file.path(getwd(), config$data_sources$def2_m2_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)


# Full Set
model_def2_3 = glmmkin(
  def2_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + bmi + pack_years + units + years + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def2_3)

def2_3_output <- select(data, c("Sample_Name"))
def2_3_output$ID2 <- data$Sample_Name
def2_3_output$residual <- as.numeric(r)

fwrite(def2_3_output, file.path(getwd(), config$data_sources$def2_m3_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)

#--------------------------------------#
# Definition 3 (EHR 10 year incidence) #
#--------------------------------------#

# Minimal Set (Age and Sex only)
model_def3_1 = glmmkin(
  def3_is_healthy ~ age + sex + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def3_1)

def3_1_output <- select(data, c("Sample_Name"))
def3_1_output$ID2 <- data$Sample_Name
def3_1_output$residual <- as.numeric(r)

fwrite(def3_1_output, file.path(getwd(), config$data_sources$def3_m1_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)

# Cell-Adjusted Set
model_def3_2 = glmmkin(
  def3_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family=binomial(link="logit")
)

r <- resid(model_def3_2)

def3_2_output <- select(data, c("Sample_Name"))
def3_2_output$ID2 <- data$Sample_Name
def3_2_output$residual <- as.numeric(r)

fwrite(def3_2_output, file.path(getwd(), config$data_sources$def2_m2_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)


# Full Set
model_def3_3 = glmmkin(
  def3_is_healthy ~ age + sex + Bcell + CD4T + CD8T + Mono + Neu + NK + bmi + pack_years + units + years + cg05575921,
  data = data,
  kins=kinship*2,
  id="Sample_Name",
  family = binomial(link = "logit")
)

r = resid(model_def3_3)

def3_3_output <- select(data, c("Sample_Name"))
def3_3_output$ID2 <- data$Sample_Name
def3_3_output$residual <- as.numeric(r)

fwrite(def3_3_output, file.path(getwd(), config$data_sources$def2_m3_output), sep=" ", col.names=FALSE, row.names=FALSE, quote = FALSE)
