"""
#### Script Information ####

Script name: s2_setzero_null.py

Purpose of script: Set zeroes as null in the converted rasters in the geodatabase
Placement in script series: #2

Outputs needed from: s1_ba_export_to_single_gdb.py

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
ap.env.parallelProcessingFactor = "100%" # Parallel processing assists in the speed of the script

# Create path to directory holding data, call it root directory
root_dir = <'Insert root directory to converted rasters here'> 
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)
ba_gdb_path = os.path.join(out_dir, <'Insert gdb name here for Wilson et al. 2013 rasters'>)

# Path to output for proportional calculations; if gdb does not exist then create it
ba_null_gdb_path = os.path.join(out_dir, 'ba_null.gdb')
if not ap.Exists(ba_null_gdb_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'ba_null.gdb')

# Set input workspace so ArcPy can find basal area rasters
ap.env.workspace = ba_gdb_path

# Join the gdb and define the raster list within it
ba_raster = os.path.join(out_dir, <'Insert gdb name here for Wilson et al. 2013 rasters'>)
ba_raster_list = ap.ListRasters()
print('Raster count should be 324: Raster count == ', len(ba_raster_list))  # check raster count

# Record start time
start_time = timeit.default_timer()

# Make sure all rasters are present or no left-over intermediary calculation rasters from copy process (script #1)
# This loop will loop through each of the 323 rasters and set 0 to null
if len(ba_raster_list) == 324:
    for ba_raster in ba_raster_list:
        outSetNull_name = '{}'.format(ba_raster)
        outSetNull_save_path = os.path.join(ba_null_gdb_path, outSetNull_name)
        if ap.Exists(outSetNull_save_path):
            print('exists: ', ba_raster)
            pass
        else:
            print('Running zeroes to null through set null for: ' + ba_raster)
            inRaster = ba_raster
            inFalseRaster = ba_raster
            whereClause = "VALUE = 0" # Value to set as null
            print('Working on setting null for: ', outSetNull_name)
            outSetNull = ap.sa.SetNull(inRaster, inFalseRaster, whereClause)
            print('***SAVING*** ', outSetNull, 'as ', outSetNull_save_path)
            outSetNull.save(outSetNull_save_path)
else:
    print('Raster list count incorrect, troubleshooting is needed')
    # If raster count != 324, will break out of loop: needs troubleshooting
    pass

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print('***FINISHED**** Setting zeroes to null in rasters took ', elapsed_min, 'minutes')