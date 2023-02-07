"""
#### README.md ####
Any questions pertaining to the scripts and/or study can be directed to the following:
Author: Justin G. Coughlin, M.S.
Email: justin.coughlin828@gmail.com

Purpose of scripts: These scripts are intended to be used for the analysis of the effects of air 
pollution (nitrogen and sulfur deposition) on 94 different prevalent tree species found across the 
contiguous United States using continuous tree species basal area and range rasters (Wilson et al., 2013). 
The methods outlined within the scripts are described in an accompanying journal article. Scripts 
should be run in sequence from s1 through s8, depending on the intended use.

Python version: 2.7
Required packages: os, timeit, arcpy (Spatial Analyst), numpy

Data repositories:

Continuous raster surfaces of tree basal area and range can be found at the following:
https://www.fs.usda.gov/rds/archive/catalog/RDS-2013-0013

Tree species effect parameters are derived from Horn et al. (2018) and can be found in the
Supplementary Information (Table S4) of the journal article here: 
https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0205296#sec015

Nitrogen and sulfur deposition raster surfaces are developed by the National Atmospheric Deposition Program's
Total Deposition Science Committee. This study utilized the 2018.2 grids (NADP, 2022) which are available, with an accompanying
README file here:
https://nadp.slh.wisc.edu/committees/tdep/


Note: These data were collected using funding from the U.S. 
Government and can be shared without additional permissions or fees.


References:
Wilson, Barry Tyler; Lister, Andrew J.; Riemann, Rachel I. 201205. A nearest-neighbor imputation approach to mapping tree species over large areas using forest inventory plots and moderate resolution raster data. Forest Ecology and Management. 271:182-198. 16 p.

Horn, K.J., Thomas, R.Q., Clark, C.M., Pardo, L.H., Fenn, M.E., Lawrence, G.B., Perakis, S.S., Smithwick, E.A., Baldwin, D., Braun, S. and Nordin, A., 2018. Growth and survival relationships of 71 tree species with nitrogen and sulfur deposition across the conterminous US. PloS one, 13(10), p.e0205296.

National Atmospheric Deposition Program (NRSP-3). 2022. NADP Program Office, Wisconsin State Laboratory of Hygiene, 465 Henry Mall, Madison, WI 53706.

"""
