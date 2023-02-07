"""
#### Script Information ####

Script name: s3_ba_sum_natl_forest.py

Purpose of script: Summation of the national forest basal area regardless of whether it is a Horn species or not
Placement in script series: #3
Previous script: s2_setzero_null.py

Notes: These data were collected using funding from the U.S.
    Government. These data may be Enforcement Confidential and may not be able to be shared.

Author: Justin G. Coughlin, M.S.
Date Created: 2020-12-10
Email: coughlin.justin@epa.gov

"""

import os
import timeit

import arcpy as ap

ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

root_dir = 'D:\coughlin\NOxSOxPMREA'
out_dir = os.path.join(root_dir, 'output_1719')

# Set scratch workspace manually to store temporary rasters from calculations
# so that remnants are not stored in output gdb if process is interrupted
# Create scratch gdb first
scratch_gdb_path = os.path.join(out_dir, 'scratch.gdb')
if not ap.Exists(scratch_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'scratch.gdb')
ap.env.scratchWorkspace = os.path.join(root_dir, 'scratch.gdb')

# Start summing process to derive national forest raster
start_time = timeit.default_timer()

# Set output path for summed raster
ba_null_gdb_path = os.path.join(out_dir, 'ba_null.gdb')
# Set input workspace so arcpy can find basal area rasters
ap.env.workspace = ba_null_gdb_path

ba_raster_list = ap.ListRasters()
print 'raster count should be 324 / raster count == ', len(ba_raster_list)  # check raster count

# Make sure all rasters are present or no left-over intermediary calculaion rasters from copy process (script #1)
if len(ba_raster_list) == 324:
    print 'summing rasters...'
    outCellStatistics = ap.sa.CellStatistics(ba_raster_list, "SUM", "DATA")
    outCellStatistics.save(os.path.join(ba_null_gdb_path, 'ba_null_natl_forest'))
else:
    print 'raster list count incorrect'
    # If raster count != 324, will break out of loop: needs troubleshooting
    pass

elapsed_min = (timeit.default_timer() - start_time) / 60
print 'summing rasters to get national forest raster took ', elapsed_min, 'minutes'
