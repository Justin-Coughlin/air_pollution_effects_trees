## Authors

Justin G. Coughlin

Email: justin.coughlin@outlook.com

## Version History

* 0.1
    * Initial Release

## License

These data were collected using funding from the U.S. Government and can be used without additional permissions or fees. 

# Description
This README describes the overarching concepts and details of the Github repository that accompanies the following journal article, [Coughlin et al. (2023)](https://doi.org/10.1371/journal.pone.0205296). 
Individual README files for the [R scripts](https://github.com/Justin-Coughlin/air_pollution_effects_trees/blob/main/r/README_R.md) and the [Python scripts](https://github.com/Justin-Coughlin/air_pollution_effects_trees/blob/main/python/README_geodatabase_file_directory.md) can be found on those links.

The two different methods take different approaches of evaluating the 2000-2019 N or S deposition impacts to the growth and/or survival of 94 different tree species. The species contained within the directories use species-specific information that was derived from findings in [Horn et al. (2018)](https://doi.org/10.1371/journal.pone.0205296) about tree species' responses to N and S deposition. The equations used in the processing scripts on the [Github repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees/tree/main/python) were modified and are described in Coughlin et al. (2023).

The R scripts can be run on a personal machine (16 GB RAM) while the Python scripts will need to be run on a physical or cloud server due to the memory needs (64+ GB RAM). These scripts can be modified to evaluate new TDep surfaces (e.g., 2018.2+) or new years (2019+). Data will need to be processed beforehand if that is the intent. For example, the tree_characteristic_deposition.csv on the [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees) could be converted into a shapefile and new deposition values could be extracted and evaluated using the scripts contained here.

# Getting Started

### Dependencies

* Prequisites:
    * Program: Python 3.x+, ArcGIS License for Spatial Analyst, Arcpy access, R

    * Storage: 200 GB

    * RAM 
        * Python: 64+ GB
        * R: 16+ GB

    * Packages: 
        * Python: os, timeit, arcpy, arcpy.SpatialAnalyst, numpy
        * R: "RColorBrewer", "ggplot2", "dplyr", "magrittr", "data.table", "tidyr", "purrr", "reshape2", "dplyr", "openxlsx", "zoo", "tictoc", "tidyverse", "lubridate", "stringr"


# File Repository
## Figshare+
This associated file directory that accompany these scripts can be found on a [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees).

## Raw Data Repositories:

Continuous raster surfaces of tree basal area and range can be found on this [USFS Website](https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0013)

Tree species effect parameters are derived from Horn et al. (2018) and can be found in the
Supplementary Information [Table S4](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0205296#sec015) contains the critical load information used here. See the [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees) for modifications that have been made to the original dataset.

Nitrogen and sulfur deposition raster surfaces are developed by the National Atmospheric Deposition Program's
Total Deposition Science Committee. This study utilized the [2018.2 grids](https://nadp.slh.wisc.edu/committees/tdep/) (NADP, 2022)

## Help

Please contact me via email if you have any issues or questions.

## References:

* Horn, K. J. et al. Growth and survival relationships of 71 tree species with nitrogen and sulfur deposition across the conterminous U.S. PLoS One (2018) doi: (10.1371/journal.pone.0205296).
* National Atmospheric Deposition Program (NRSP-3). 2022. NADP Program Office, Wisconsin State Laboratory of Hygiene, 465 Henry Mall, Madison, WI 53706.
