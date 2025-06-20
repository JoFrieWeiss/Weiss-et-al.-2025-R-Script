# SEM Analysis of Climate and Algae Data

This repository contains an R script to perform Structural Equation Modeling (SEM) on climate proxies, algae group abundances, and microbial/CO₂ response variables from paleoclimate data. The script includes data interpolation, normalization, exploratory plotting, and SEM construction and comparison using the `piecewiseSEM` package.

## Files

- `SEM_analysis.R`: Main script for data preparation, interpolation, and SEM modeling.
- `plot_Interpolated_Data.R`: Custom plotting function for visualizing interpolation results.
- `SEM model data_Yosfine.xlsx`: Input Excel file containing the following sheets:
  - **Climate**: Age and climate proxies (e.g., EDC_D, IPSO25)
  - **algae**: Age and relative abundance of Chaetoceros, Fragilariopsis, Micromonas, Phaeocystis
  - **response**: Age and response variables (e.g., Ba/Fe, methylotrophs, CO₂)

## Requirements

Install the following R packages if not already installed:

```r
install.packages(c("nlme", "piecewiseSEM", "car", "lmtest", "semTools", 
                   "bestNormalize", "readxl", "rioja", "ggplot2", "gridExtra"))

