## Authors

Justin G. Coughlin

Email: justin.coughlin@outlook.com

Christopher M. Clark

clark.christopher@epa.gov

## Version History

* 0.1
    * Initial Release

## License

These data were collected using funding from the U.S. Government and can be used without additional permissions or fees. 

# File Directory for Rasters
This file directory is intended to serve as a README file for the continuous surfaces of N and S deposition effects to 94 tree species in the contiguous United States.
There is accompanying material on a [Github repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees) if the user intends to process data themselves.

## Description
This file directory describes various raster geodatabase files generated as a research product from Coughlin et al. (2023).
Rasters include the spp code that is used by the United States Forest Service (USFS) as unique identifiers for tree species. 
The basal area rasters that were used here are available from the USFS at the following site:
* [Basal area rasters](https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0013)

The directory includes:

* **aggregate.gdb**: 
    * *Aggregated rasters for interspecific evaluations.* 
* **ba_null.gdb**: 
    * *Basal area rasters that have been nulled. These rasters are directly from the USFS database with NA placeholder values nulled.*
* **N_basal_area_prop_growth_effect.gdb**: 
    * *Species-specific proportional basal area effect (m<sup>2</sup> ha<sup>-1</sup>) for growth based on 2017-2019 average N deposition.*
* **N_basal_area_prop_survival_effect.gdb**: 
    * *Species-specific proportional basal area effect (m<sup>2</sup> ha<sup>-1</sup>) for survival based on 2017-2019 average N deposition.*
* **N_growth_deposition_5_red.gdb**: 
    * *Total N deposition level (kg N ha<sup>-1</sup> yr<sup>-1</sup>) needed to prevent a 5% reduction in growth for individual species.*
* **N_growth_effect.gdb**: 
    * *Species-specific growth effects (proportion, e.g., +0.05 is a 5% increase in growth rate) due to N deposition owing to 2017-2019 total N deposition.*
* **N_survival_deposition_1_red.gdb**: 
    * *Total N deposition level (kg N ha<sup>-1</sup> yr<sup>-1</sup>) needed to prevent a 1% reduction in survival for individual species.*
* **N_survival_effect.gdb**: 
    * *Species-specific survival effects (proportion, e.g.,- 0.01 is a -1% effect in survival rate) due to N deposition owing to 2017-2019 total N deposition.*
* **S_basal_area_prop_growth_effect.gdb**: 
    * *Species-specific proportional basal area effect (m<sup>2</sup> ha<sup>-1</sup>) for growth based on 2017-2019 average S deposition.*
* **S_basal_area_prop_survival_effect.gdb**: 
    * *Species-specific proportional basal area effect (m<sup>2</sup> ha<sup>-1</sup>) for survival based on 2017-2019 average S deposition.*
* **S_growth_deposition_5_red.gdb**: 
    * *Total S deposition level (kg S ha<sup>-1</sup> yr<sup>-1</sup>) needed to prevent a 5% reduction in growth for individual species.*
* **S_growth_effect.gdb**: 
    * *Species-specific growth effects (proportion, e.g.,- 0.05 is a -5% effect in growth rate) due to S deposition owing to 2017-2019 total N deposition.*
* **S_survival_deposition_1_red.gdb**: 
    * *Total S deposition level (kg S ha<sup>-1</sup> yr<sup>-1</sup>) needed to prevent a 1% reduction in survival for individual species.*
* **S_survival_effect.gdb**: 
    * *Species-specific survival effects (proportion, e.g.,- 0.01 is a -1% effect in survival rate) due to S deposition owing to 2017-2019 total N deposition.*
* **spp_proportion_ba.gdb**: 
    * *Species-specific proportion to total basal area using all 323 species from the USFS database.*

All geodatabases are species-specific (i.e., spp code) except for aggregate.gdb. The species contained accompanying scripts and README documentation can be found at the following code repository:
* [Processing Scripts](https://github.com/Justin-Coughlin/air_pollution_effects_trees)

In effects rasters, the effect is the proportional effect. For example, a value of -0.5 is a 50% decrease (i.e., reduction) in the growth or survival rate. Conversely, 1.0 would be a 100% increase. Typical values 
will vary widely between -1.0 to 2.0+. In deposition rasters, the deposition level for individual species is the deposition level (kg N or S ha<sup>-1</sup> yr<sup>-1</sup>) that is needed to prevent a 5% (growth) or
1% (survival) rate reduction. In the basal area rasters, the proportional effect to the basal area (m<sup>2</sup> ha<sup>-1</sup>) for an invididual species is presented. Aggregate rasters will have the same units, respectively, depending on the raster (e.g., effects).

The species contained within the directories use species-specific information that was derived from findings in [Horn et al. (2018)](https://doi.org/10.1371/journal.pone.0205296) about tree species' responses to N and S deposition. The equations used in the processing scripts on the [Github repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees/tree/main/python) were modified and are described in Coughlin et al. (2023).

## Getting Started

### Dependencies

* Prequisites:
    * OS: Python 3.x+, ArcGIS License for Spatial Analyst, Arcpy access, R

    * Storage: 200 GB

    * RAM 
        * Python: 64+ GB
        * R: 16+ GB

    * Packages: 
        * Python: os, timeit, arcpy, arcpy.SpatialAnalyst, numpy
        * R: "RColorBrewer", "ggplot2", "dplyr", "magrittr", "data.table", "tidyr", "purrr", "reshape2", "dplyr", "openxlsx", "zoo", "tictoc", "tidyverse", "lubridate", "stringr"

### Installing
You can download the data from the geodatabases directly on this [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees).
Additional instructions on the process for downloading, see below: 
```
1. Download the entire folder directory of interest. Raster files will contain multiple files (3-8), 
   so it is crucial to download the entire geodatabase folder.

2. Once downloaded, access the geodatabase using your preferred GIS software.

3. Please use the metadata_gdb.csv file as the point of reference for 
   selecting the species of interest or the aggregate raster of interest.
```
## Help

Common issues to be aware of:
```
- Ensure the proper projection is being used (Albers projection, GRS1980 datum) 
- Ensure the entire folder directory is downloaded to use the geodatabase in your preferred GIS software
- Ensure you have enough RAM to use the processing scripts.
```
Please contact me via email if you have any issues or questions.

## References:

* Horn, K. J. et al. Growth and survival relationships of 71 tree species with nitrogen and sulfur deposition across the conterminous U.S. PLoS One (2018) doi: (10.1371/journal.pone.0205296).
* Thomas, R. Q., Canham, C. D., Weathers, K. C. & Goodale, C. L. Increased tree carbon storage in response to nitrogen deposition in the US. Nat Geosci (2010) doi:10.1038/ngeo721.
