# Carbon drawdown by algal blooms during Antarctic Cold Reversal from sedimentary aDNA

## Description

This R script processes metagenomic sequencing data from sedimentary ancient DNA (sedaDNA) to investigate the dominance of *Phaeocystis antarctica* during the Antarctic Cold Reversal (ACR). It performs:

- Data cleaning and integration of Kraken2 taxonomy outputs  
- Filtering for eukaryotic taxa and phytoplankton  
- Aggregation and normalization of taxa at genus level  
- Resampling (rarefaction) for sample comparability  
- Visualization of relative abundances over time  
- Inclusion of ice core climate data (EPICA community members (2004); Monnin et al., 2001) and geochemical XRF data (Vorrath et al., 2023)
- Plotting biomarker proxies related to sea ice (Vorrath et al., 2023)

  References

  Monnin, E., Indermuhle, A., Dallenbach, A., Fluckiger, J., Stauffer, B., Stocker, T. F., ... & Barnola, J. M. (2001). Atmospheric CO2 concentrations over the last glacial termination. Science, 291(5501), 112-114.
  EPICA community members. (2004). Eight glacial cycles from an Antarctic ice core. Nature, 429(6992), 623-628.
  Vorrath, M. E., Müller, J., Cárdenas, P., Opel, T., Mieruch, S., Esper, O., ... & Mollenhauer, G. (2023). Deglacial and Holocene sea-ice and climate dynamics in the Bransfield Strait, northern Antarctic Peninsula. Climate of the Past, 19(5), 1061-1079.
  
## Usage

1. Place the required input files (Kraken2 outputs, taxonomic lineage files, ice core data, geochemical data) in the appropriate folders.
   -> Raw data can be found in the ENA database under the accessory number: PRJEB74305 
3. Adjust file paths in the script as needed.  
4. Run the R script in RStudio or an R environment.  
5. Output plots and processed data will be generated in the working directory.

## Dependencies

The following R packages are required:

- `dplyr`  
- `tidyverse`  
- `readxl`  
- `tidypaleo`  
- `ggplot2`  
- `readr`  
- `ggpubr`  
- `compositions`  

Install missing packages with:

```r
install.packages(c("dplyr", "tidyverse", "readxl", "tidypaleo", "ggplot2", "readr", "ggpubr", "compositions"))
