"""
#### Script Information ####

Script name: s2_setzero_null.py

Purpose of script: Set zeroes as null in the converted rasters in the geodatabase
Placement in script series: #2
Previous script: s1_ba_export_to_single_gdb.py

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

# Set environment settings
root_dir = 'D:\coughlin\NOxSOxPMREA'
out_dir = os.path.join(root_dir, 'output_1719')
ba_gdb_path = os.path.join(out_dir, 'ba.gdb')

# Path to output for proportional calculations; if gdb does not exist then create it
ba_null_gdb_path = os.path.join(out_dir, 'ba_null.gdb')
if not ap.Exists(ba_null_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'ba_null.gdb')

# Set input workspace so ArcPy can find basal area rasters
ap.env.workspace = ba_gdb_path

# Join the gdb and define the raster list within it
ba_raster = os.path.join(out_dir, 'ba.gdb')
ba_raster_list = ap.ListRasters()
print 'raster count should be 324 / raster count == ', len(ba_raster_list)  # check raster count

# Record start time
start_time = timeit.default_timer()

# Make sure all rasters are present or no left-over intermediary calculation rasters from copy process (script #1)
if len(ba_raster_list) == 324:
    for ba_raster in ba_raster_list:
        outSetNull_name = '{}'.format(ba_raster)
        outSetNull_save_path = os.path.join(ba_null_gdb_path, outSetNull_name)
        if ap.Exists(outSetNull_save_path):
            print 'exists: ', ba_raster
            pass
        else:
            print 'running zeroes to null through set null for: ' + ba_raster
            inRaster = ba_raster
            inFalseRaster = ba_raster
            whereClause = "VALUE = 0"
            print 'working on setting null for: ', outSetNull_name
            outSetNull = ap.sa.SetNull(inRaster, inFalseRaster, whereClause)
            print '***SAVING*** ', outSetNull, 'as ', outSetNull_save_path
            outSetNull.save(outSetNull_save_path)
else:
    print 'raster list count incorrect'
    # If raster count != 324, will break out of loop: needs troubleshooting
    pass

elapsed_min = (timeit.default_timer() - start_time) / 60
print '***FINISHED**** setting zeroes to null in rasters took ', elapsed_min, 'minutes'