## Authors

Justin G. Coughlin

Email: justin.coughlin@outlook.com

## Version History

* 0.1
    * Initial Release

## License

These data were collected using funding from the U.S. Government and can be used without additional permissions or fees. 

## Description
This README file is intended to serve as a crosswalk for evaluating N and S deposition effects to 94 tree species, 
at Forest Inventory and Analysis (FIA) plots, across the contiguous United States. This README describes the R scripts themselves.
The accompanying data is available on a [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees). 
Data within the repository is necessary to run the R scripts. Additionally, data outputs from the R scripts are described in this
script and on the figshare+ repository.

The R scripts include:

* **calculate_effects.R**: 
    * *This script evaluates raw data from Horn et al. (2018) that has been spatially joined with 2000-2019 NADP TDep surfaces of total N and S deposition.* 
    *This scripts will export the dataset that is used to evaluate the plot-level data from FIA. Summary statistics tables are also calculated after processing has taken place.*
* **Fig_1.R**: 
    * *This script generates Fig 1 in the main manuscripts.*  
* **Fig_2.R**: 
    * *This script generates Fig 2 in the main manuscripts.*
* **Fig_4.R**: 
    * *This script generates Fig 4 in the main manuscripts.*
* **Fig_5a.R**: 
    * *This script generates Fig 5a in the main manuscripts.*  
* **Fig_6b.R**: 
    * *This script generates Fig 6b in the main manuscripts.* 
* **Extended_Data_Figs.R**: 
    * *This script generates the extended data figs in the main manuscripts.*  

The species contained within the directories use species-specific information that was derived from findings in [Horn et al. (2018)](https://doi.org/10.1371/journal.pone.0205296) about tree species' responses to N and S deposition. The equations used in the processing scripts on the [Github repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees/tree/main/python) were modified and are described in Coughlin et al. (2023).

## Getting Started

### Dependencies

* Prequisites:
    * Program: R

    * Storage: 5 GB

    * Packages: 
        * R: "RColorBrewer", "ggplot2", "dplyr", "magrittr", "data.table", "tidyr", "purrr", "reshape2", "dplyr", "openxlsx", "zoo", "tictoc", "tidyverse", "lubridate", "stringr"

### Installing
You can download the data from the data needed to process these scripts directly on this [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees).

## Help

Please contact me via email if you have any issues or questions.

## References:

* Horn, K. J. et al. Growth and survival relationships of 71 tree species with nitrogen and sulfur deposition across the conterminous U.S. PLoS One (2018) doi: (10.1371/journal.pone.0205296).