# ===============================================
# Script for SEM analysis of climate and algae data
# Description: Loads, interpolates, visualizes, 
#              and models environmental and biological data
# ===============================================

# --------- 1. Load packages ---------
# Uncomment below if first run
# install.packages("piecewiseSEM")

library(nlme)
library(piecewiseSEM)
library(car)
library(lmtest)
library(semTools)
library(bestNormalize)
library(readxl)
library(rioja)
library(ggplot2)
library(gridExtra)

# --------- 2. Set working directory and source utility functions ---------
setwd("C:/Users/jie liang/Downloads/Yosfina")
source("plot_Interpolated_Data.R")   # Custom plotting function

# --------- 3. Read data ---------
path <- "SEM model data_Yosfine.xlsx"
climate_df <- read_excel(path, sheet = "Climate")
algae_df   <- read_excel(path, sheet = "algae")
response_df<- read_excel(path, sheet = "response")

# --------- 4. Data normalization/preprocessing ---------
# Calculate row sums for algae groups (columns 2:5) and convert to percentage
row_sums <- rowSums(algae_df[, 2:5])
algae_df[, 2:5] <- sweep(algae_df[, 2:5], 1, row_sums, FUN = "/") * 100

# --------- 5. Interpolation ---------
age_interp <- seq(100, 14000, by=300)

# Interpolate Climate variable (EDC_D)
EDC_D.interp <- interp.dataset(
  y=climate_df[, c(2,2)], x=climate_df$Age_EDC_D, 
  xout=age_interp, method=c("sspline"), rep.negt=FALSE)

# Plot interpolated Climate variable
plot_Interpolated_Data(climate_df[, 1], climate_df[, 2], age_interp, EDC_D.interp[, 1])

# Interpolate another climate variable (PBIPSO25)
df <- climate_df[, 3:4]
df <- df[complete.cases(df), ]
PBIPSO25.interp <- interp.dataset(
  y=df[, c(2,2)], x=df$age, 
  xout=age_interp, method=c("sspline"))

# Interpolate algae group percentages
algae.interp <- interp.dataset(
  y=algae_df[, 2:5], x=algae_df$age, 
  xout=age_interp, method=c("sspline"))

# Interpolate response variables
df1 <- response_df[, 1:4]
df1 <- df1[complete.cases(df1), ]
Ba.Fe.interp <- -interp.dataset(
  y=abs(df1[, c(2,2)]), x=df1$age, 
  xout=age_interp, method=c("sspline"))
methylotrophs.interp <- interp.dataset(
  y=df1[, c(3,4)], x=df1$age, 
  xout=age_interp, method=c("sspline"))
CO2_ppmv.interp <- interp.dataset(
  y=response_df[, c(6,6)], x=response_df$Gas_age_a_BP, 
  xout=age_interp, method=c("sspline"))

# --------- 6. Plot interpolated results (optional, for sanity check) ---------
EDC_D_P   <- plot_Interpolated_Data(climate_df[, 1], climate_df[, 2], age_interp, EDC_D.interp[, 1])
IS25_P    <- plot_Interpolated_Data(df[, 1], df[, 2], age_interp, PBIPSO25.interp[, 1])
algae_P1  <- plot_Interpolated_Data(algae_df[, 1], algae_df[, 2], age_interp, algae.interp[, 1])
algae_P2  <- plot_Interpolated_Data(algae_df[, 1], algae_df[, 3], age_interp, algae.interp[, 2])
algae_P3  <- plot_Interpolated_Data(algae_df[, 1], algae_df[, 4], age_interp, algae.interp[, 3])
algae_P4  <- plot_Interpolated_Data(algae_df[, 1], algae_df[, 5], age_interp, algae.interp[, 4])
Ba.Fe_P   <- plot_Interpolated_Data(response_df[, 1], response_df[, 2], age_interp, Ba.Fe.interp[, 1])
methylotrophs_p1 <- plot_Interpolated_Data(response_df[, 1], response_df[, 3], age_interp, methylotrophs.interp[, 1])
methylotrophs_p2 <- plot_Interpolated_Data(response_df[, 1], response_df[, 4], age_interp, methylotrophs.interp[, 2])
CO2__p    <- plot_Interpolated_Data(response_df[, 5], response_df[, 6], age_interp, CO2_ppmv.interp[, 1])

# --------- 7. Build final SEM dataset ---------
dataset <- data.frame(
  age_interp, 
  EDC_D.interp[, 1],
  PBIPSO25.interp[, 1],
  algae.interp,
  Ba.Fe.interp[, 1],
  methylotrophs.interp,
  CO2_ppmv.interp[, 1]
)

colnames(dataset) <- c(
  "age", "EDC_D", "IPSO25", "Chaetoceros", "Fragilariopsis", 
  "Micromonas", "Phaeocystis", "Ba.Fe", 
  "sumcount_of_methylotrophs", "percentage_of_methylotrophs", "CO2_ppmv"
)

# --------- 8. Data transformation (log) ---------
dataset$Chaetoceros_log    <- log(dataset$Chaetoceros + 1)
dataset$Fragilariopsis_log <- log(dataset$Fragilariopsis + 1)
dataset$Phaeocystis_log    <- log(dataset$Phaeocystis + 1)
dataset$EDC_D              <- log_x(dataset$EDC_D)$x.t 

# --------- 9. Exploratory plots ---------
# Linear relationships between main variables and CO2
a1 <- ggplot(dataset, aes(x = Chaetoceros, y = CO2_ppmv)) + geom_smooth(method='lm') + geom_point()
a2 <- ggplot(dataset, aes(x = Fragilariopsis, y = CO2_ppmv)) + geom_smooth(method='lm') + geom_point()
a3 <- ggplot(dataset, aes(x = Phaeocystis, y = CO2_ppmv)) + geom_smooth(method='lm') + geom_point()
a4 <- ggplot(dataset, aes(x = Micromonas, y = CO2_ppmv)) + geom_smooth(method='lm') + geom_point()
grid.arrange(a1, a2, a3, a4, ncol = 2)

# --------- 10. SEM modeling ---------
# Build candidate mixed effect models for SEM paths
model1 <- lme(Chaetoceros_log    ~ EDC_D + IPSO25, random = ~ 1 | age, data = dataset)
model2 <- lme(Fragilariopsis_log ~ EDC_D + IPSO25, random = ~ 1 | age, data = dataset)
model3 <- lme(Phaeocystis_log    ~ EDC_D + IPSO25, random = ~ 1 | age, data = dataset)
model5 <- lme(percentage_of_methylotrophs ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log, random = ~ 1 | age, data = dataset)
model6 <- lme(Ba.Fe ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log, random = ~ 1 | age, data = dataset)
model7 <- lme(CO2_ppmv ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log, random = ~ 1 | age, data = dataset)

# Build SEM models with different path/correlation structures
sem_model.1 <- psem(model1, model2, model3, model5, model6, model7, data=dataset)
s  <- summary(sem_model.1, standardize = "none", conserve = TRUE)

# SEM model 2: add correlated errors among predictors
sem_model.2 <- psem(
  model1, model2, model3, model5, model6, model7, 
  Phaeocystis_log %~~% Fragilariopsis_log,
  Phaeocystis_log %~~% Chaetoceros_log,
  Fragilariopsis_log %~~% Chaetoceros_log,
  data = dataset
)
s2 <- summary(sem_model.2, standardize = "none")

# SEM model 3: update with more complex structure
model5 <- lme(percentage_of_methylotrophs ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log + IPSO25, random = ~ 1 | age, data = dataset)
model6 <- lme(Ba.Fe ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log + percentage_of_methylotrophs, random = ~ 1 | age, data = dataset)
model7 <- lme(CO2_ppmv ~ Phaeocystis_log + Fragilariopsis_log + Chaetoceros_log + Ba.Fe, random = ~ 1 | age, data = dataset)

sem_model.3 <- psem(
  model1, model2, model3, model5, model6, model7,
  Phaeocystis_log %~~% Fragilariopsis_log,
  Fragilariopsis_log %~~% Chaetoceros_log,
  Phaeocystis_log %~~% Chaetoceros_log
)
s3 <- summary(sem_model.3, standardize = "scale")

# --------- 11. Compare model fit statistics ---------
aic_model1 <- AIC_psem(sem_model.1)
aic_model2 <- AIC_psem(sem_model.2)
aic_model3 <- AIC_psem(sem_model.3)

model_comparison <- data.frame(
  Model = c("Model1", "Model2", "Model3"),
  AIC   = c(aic_model1$AIC, aic_model2$AIC, aic_model3$AIC),
  AICc  = c(aic_model1$AICc, aic_model2$AICc, aic_model3$AICc),
  Chisq = c(s$ChiSq$Chisq, s2$ChiSq$Chisq, s3$ChiSq$Chisq),
  Chisq_p_value = c(s$ChiSq$P.Value, s2$ChiSq$P.Value, s3$ChiSq$P.Value),
  Fisher.C = c(s$Cstat$Fisher.C, s2$Cstat$Fisher.C, s3$Cstat$Fisher.C),
  Fisher.C_p_value = c(s$Cstat$P.Value, s2$Cstat$P.Value, s3$Cstat$P.Value)
)
print(model_comparison)

# --------- 12. (Optional) Visualize best SEM ---------
plot(sem_model.3, title = "lme SEM")

# ===============================================
# End of Script
# ===============================================
