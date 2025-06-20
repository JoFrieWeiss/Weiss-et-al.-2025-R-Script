# TRAY Calculation Preparation and NPP Progression Analysis

This repository contains R code to prepare and analyze data related to CO₂ trends and Net Primary Production (NPP) during different climate phases, with a focus on the Antarctic Cold Reversal (ACR) period. The analysis integrates ice core CO₂ data with biological proxies to assess ecosystem contributions to atmospheric CO₂ changes.

## Overview

The workflow performs the following key steps:

1. **CO₂ Linear Regression Modeling**
   - Load and preprocess CO₂ data from the West Antarctic Ice Sheet Divide (WDC) ice core.
   - Filter the data to exclude the ACR plateau period.
   - Fit a linear regression model to CO₂ concentration as a function of age (years before present).
   - Visualize the regression fit against observed CO₂ values.
   - Predict CO₂ concentrations across the full age range using the fitted model.

2. **NPP Progression Calculation**
   - Load datasets including:
     - Total carbon model outputs,
     - Calculated NPP values for different phytoplankton groups,
     - Linear regression CO₂ predictions.
   - Subset and merge relevant columns across datasets.
   - Calculate the NPP progression ratios for each phytoplankton group relative to the pre-ACR baseline.
   - Combine the results into a final dataset for further analysis.

## Dependencies

- R (version >= 4.0)
- tidyverse (for data manipulation and plotting)
- readxl (for reading Excel files)

## Usage

1. Load the required R packages.
2. Import the provided .RData.
3. Run the script to:
   - Fit the CO₂ linear regression model.
   - Calculate NPP progression ratios.
   - Visualize the CO₂ linear model fit.

## Example Plot

The script produces a plot showing:

- Original CO₂ measurements (black points),
- Linear regression fit (blue line),
- Highlighted ACR plateau period (red line segment).

## Contact

For questions or suggestions, please contact Josefine Friederike Weiß at josefine-friederike.weiss@awi.de .

---

*This analysis is part of ongoing research into the role of phytoplankton and carbon cycling during abrupt climate events.*

