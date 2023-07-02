"""
#### Script Information ####

Script name: s3_ba_sum_natl_forest.py

Purpose of script: Summation of the national forest basal area from the 323 basal area rasters

Placement in script series: #3
Outputs needed from: s1_ba_export_to_single_gdb.py, s2_setzero_null.py

Author: Justin G. Coughlin, M.S.
Date Created: 2020-12-10
Modified: 2023-07-02
Email: justin.coughlin@outlook.com

"""

# Import the necessary modules
import os
import timeit
import arcpy as ap

# Set up environment
ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%" # Parallel processing assists in the speed

root_dir = <'Insert root directory to converted rasters here'> 
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)

# Set scratch workspace manually to store temporary rasters from calculations
# so that remnants are not stored in output gdb if process is interrupted
# Create scratch gdb first
scratch_gdb_path = os.path.join(out_dir, 'scratch.gdb')
if not ap.Exists(scratch_gdb_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'scratch.gdb')
ap.env.scratchWorkspace = os.path.join(root_dir, 'scratch.gdb')

# Start summing process to derive national forest raster
start_time = timeit.default_timer()

# Set output path for summed raster
ba_null_gdb_path = os.path.join(out_dir, 'ba_null.gdb')
# Set input workspace so arcpy can find basal area rasters
ap.env.workspace = ba_null_gdb_path

# List the rasters 
ba_raster_list = ap.ListRasters()
print('Raster count should be 324: Raster count == ', len(ba_raster_list))  # check raster count

# Make sure all rasters are present or no left-over intermediary calculaion rasters from copy process (script #1)
if len(ba_raster_list) == 324:
    print('Summing rasters...')
    outCellStatistics = ap.sa.CellStatistics(ba_raster_list, "SUM", "DATA")
    outCellStatistics.save(os.path.join(ba_null_gdb_path, 'ba_null_natl_forest'))
else:
    print('Raster list count incorrect')
    # If raster count != 324, will break out of loop: needs troubleshooting
    pass

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print('Summing rasters to get national forest raster took ', elapsed_min, 'minutes')
