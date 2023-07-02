"""
#### Script Information ####

Script name: s7_calculate_summary_rasters.py

Purpose of script: Calculate an aggregated value of effects 
    from all species' effects rasters. Currently set to do the fifth percentile.

Placement in script series: #7
Outputs needed from: s1_ba_export_to_single_gdb.py, s2_setzero_null.py, 
    s3_ba_sum_natl_forest.py, s4_select_horn_spp_calc_proportion.py,
    s6a_effects_eqn_growth.py or s6b_eqn_survival.py
Adjustment for TDep: Runs will be adjusted based on TDep raster years. Change suffix where necessary.
    I.e.,  line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))

Note: This script is burdensome on RAM usage. A minimum of 64 GB RAM is needed for to run this script.
    If that amount of RAM s unavailable, tiling can be done within the script then mosaicked back together.
    A tiling/mosaic code chunk is not currently contained within the script.

    Additionally, this script can be used for the outputs from 9a and 9b to determine the fifth
    percentile of deposition needed to prevent an x% reduction in growth or survival.

Author: Justin G. Coughlin, M.S.
Date Created: 2020-12-10
Modified: 2023-07-02
Email: justin.coughlin@outlook.com

"""

# Import the necessary modules
import os
import timeit
import numpy as np
import arcpy as ap

# Set up environment
ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# Set path general output directory
root_dir = <'Insert root directory to converted rasters here'> 
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)
aggregate_out_path = os.path.join(out_dir, 'aggregate.gdb')
if not ap.Exists(aggregate_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'aggregate.gdb')

# Create variable lists for looping thru
response_variables = ['survival', 'growth']
elements = ['s', 'n']

# Record start time
start_time = timeit.default_timer()
print('Beginning the raster to numpy process...')

# Begin the aggregate calculation; default setting is 5th percentile
for response_variable in response_variables:
    for element in elements:
        rdxn_path = os.path.join(out_dir, '{}_{}_deposition_5_red.gdb'.format(element.capitalize(), response_variable))
        ap.env.workspace = rdxn_path
        rasters = ap.ListRasters()
        out_raster_name = 'dep_percentile_5_{}_{}'.format(response_variable, element)
        out_raster_save_path = os.path.join(os.path.join(out_dir, 'aggregate.gdb'), out_raster_name)
        if ap.Exists(out_raster_save_path):
            print('out file name = ', out_raster_name)
            print(' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path)
            print('going to next raster', '\n')
        else:
            print('does not exist in output gdb, .....process raster ', out_raster_name)
            print('redxn raster will be saved to : ', out_raster_save_path, '\n')
            print('**setting the environment including cell size, spatial ref, and snap')
            
            # Set environments to handle differing resolutions rasters
            # set output coordinate system
            spatial_ref = ap.SpatialReference(5070) # 5070 = Equal Area Conus Albers
            ap.env.outputCoordinateSystem = spatial_ref
            ap.env.cellSize = rdxn_path
            ap.env.snapRaster = rdxn_path
            
            # Create rasters to numpy arrays. Append the arrays.
            arrs = []
            for raster in rasters:
                print('Converting raster to numpy for: ', raster, 'in ', rdxn_path)
                arrs.append(ap.RasterToNumPyArray(raster, nodata_to_value=100000)) # NAs to 100000
                # The master array
            
            # Create median effect raster to use as the extent 
            print('Creating median raster for extent...')
            CellStat = ap.sa.CellStatistics(rasters, 'MEDIAN')
            # ---- Save the result out to a new raster ------
            print('Setting up new raster dataset...')
            lower_left = CellStat.extent.lowerLeft  # ---- needed to produce output
            cell_size = CellStat.meanCellHeight  # ---- we will use this for x and y
            
            # Convert appended arrays into full stack, mask NAs that have been converted
            print('Converting appended arrays to full stack array...')
            a = np.array(arrs)
            ma = np.ma.masked_values(a, 100000.000000)
            ma_nan = np.ma.filled(ma, np.nan)
            
            # Conduct the fifth percentile calculation
            print('Calculating percentile including NAs...')
            # Aggregate calculation. Calculates the percentile through the '0' axis (i.e., vertically, nort horizontally) 
            percentile_5 = np.nanpercentile(ma_nan, 5, axis=0) # Set the percentile here, replace '5' with desired percentile.
            print('Converting numpy to raster...')
            out_percentile = ap.NumPyArrayToRaster(percentile_5, lower_left, cell_size, cell_size)
            out_percentile.save(out_raster_save_path)
            del a, ma, ma_nan, out_percentile # Clean up environment

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print('creating aggregate effect rasters took', elapsed_min, 'minutes')