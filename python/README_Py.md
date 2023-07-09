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
using continuous basal area surfaces, across the contiguous United States. This README describes the .py scripts that
were used in [Coughlin et al. (2023)](https://github.com/Justin-Coughlin/air_pollution_effects_trees) to generate 
continuous surfaces of N and S deposition effects to tree species.

The accompanying data is available on a [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees). 
The continuous surface data were originally based on the following dataset:
* [Basal area rasters; Wilson et al. (2013)](https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0013)

Data within the [figshare+ repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees) are necessary to run the .py scripts. 

The R scripts include:

* **s1_ba_export_to_single_gdb.py**: 
    * *This script takes the downloaded files from Wilson et al. (2013) and files them into a single geodatabase (gdb).* 
    * *Requires: Downloaded files from [Wilson et al. (2013)](https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0013)
    * *Generates: ba.gdb*
* **s2_setzero_null.py**: 
    * *This script goes through all of the basal area rasters and sets null values to remove placeholder NA.* 
    * *Requires: ba.gdb* 
    * *Generates: ba_null.gdb*
* **s3_ba_sum_natl_forest.py.R**: 
    * *This script sums all of the nulled basal area rasters to generate a total forest basal area raster.* 
    * *Requires: ba_null.gdb* 
    * *Generates: ba_null_natl_forest*
* **s4_select_horn_spp_calc_proportion.py**: 
    * *This script determines the proportion to total forest basal area for each individual species.* 
    * *Requires: ba_null.gdb, ba_null_natl_forest* 
    * *Generates: spp_proportion_ba.gdb*
* **s5_calculate_wilson_exceedance.py**: 
    * *This script evaluates whether each species is in exceedance of its critical load. The csv files must be in the same folder directory to be used in the search cursor.* 
    * *Requires: spp_proportion_ba.gdb, horn_growth.csv, horn_survival.csv* 
    * *Generates: ba.gdb*
* **s6a_effects_eqn_growth.py**: 
    * *This script calculates the proportional effect to a species growth rate based on the selected year of deposition. Default is set to 2017-2019 average.* 
    * *Requires: spp_proportion_ba.gdb, horn_growth.csv*  
    * *Generates: N_growth_effect.gdb, S_growth_effect.gdb*
* **s6a_effects_eqn_survival.py**:  
    * *This script calculates the proportional effect to a species survival rate based on the selected year of deposition. Default is set to 2017-2019 average.* 
    * *Requires: spp_proportion_ba.gdb, horn_survival.csv*  
    * *Generates: N_survival_effect.gdb, S_survival_effect.gdb*
* **s7_calculate_summary_rasters.py**: 
    * *This script calculates summary statistics, such as the fifth percentile. It is similar to the ArcGIS tool, cell statistics, but is able to process percentiles.*
    * *This script can also be used for outputs from s9a and s9b if percentiles for deposition levels needed are desired. Default is set to outputs from s6a and s6b and the 5th percentile* 
    * *Requires: N_growth_effect.gdb, S_growth_effect.gdb, N_survival_effect.gdb, S_survival_effect.gdb or outputs from s9a/s9b* 
    * *Generates: percentile raster for selected rasters*
* **s8_basal_area_weight_effects.py**:
    * *This script generates the weighted basal area effect for an individual species based on a selected year of deposition. Default is set to 2017-2019 average deposition.*
    * *Requires: spp_proportion_ba.gdb, N_growth_effect.gdb, S_growth_effect.gdb, N_survival_effect.gdb, S_survival_effect.gdb* 
    * *Generates: N_basal_area_prop_growth_effects.gdb, S_basal_area_prop_growth_effects.gdb, N_basal_area_prop_survival_effects.gdb, S_basal_area_prop_survival_effects.gdb* 
* **s9a_deposition_level_for_growth_reduction.py**: 
    * *This script calculates the deposition level needed to prevent an x% reduction in growth rate for each species. Default is set to 5% reductions in growth rate.* 
    * *Requires: spp_proportion_ba.gdb, growth.csv in the gdb as a table* 
    * *Generates: N_growth_deposition_5_red.gdb, S_growth_deposition_5_red.gdb*
* **s9b_deposition_level_for_survival_reduction.py**: 
    * *This script calculates the deposition level needed to prevent an x% reduction in survival rate for each species. Default is set to 1% reductions in growth rate.* 
    * *Requires: spp_proportion_ba.gdb, survival.csv in the gdb as a table* 
    * *Generates: N_survival_deposition_1_red.gdb, S_survival_deposition_1_red.gdb*

The species contained within the directories use species-specific information that was derived from findings in [Horn et al. (2018)](https://doi.org/10.1371/journal.pone.0205296) about tree species' responses to N and S deposition. The equations used in the processing scripts on the [Github repository](https://github.com/Justin-Coughlin/air_pollution_effects_trees/tree/main/python) were modified and are described in Coughlin et al. (2023).

## Getting Started

### Dependencies

* Prequisites:
    * Program: Python 3.x+, ArcGIS License for Spatial Analyst, Arcpy access

    * Storage: 200 GB

    * RAM 
        * Python: 64+ GB

    * Packages: 
        * Python: os, timeit, arcpy, arcpy.SpatialAnalyst, numpy

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
* Wilson, B. T., Lister, A. J., Riemann, R. I. & Griffith, D. M. Live tree species basal area of the contiguous United States (2000-2009) Data. in USDA Research Data Archive (2013).