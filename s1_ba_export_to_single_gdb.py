"""
#### Script Information ####

Script name: s1_ba_export_to_single_gdb.py

Purpose of script: Export e00 converted rasters to single gdb for faster processing within ArcPy
Placement in script series: #1
Previous script: NA
Pre-setup: Create a root folder and put all of the data into it; this script will then create a single output folder
    named 'output' to hold all of the outputs. Subsequent scripts will create gdbs within 'output' folder to hold
    additional outputs as needed.

Notes: These data were collected using funding from the U.S.
    Government and can be shared without additional permissions or fees.

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

# Create path to directory holding data, call it root directory
root_dir = 'D:\coughlin\NOxSOxPMREA'

# Create general output directory for all succeeding scripts / create directory if not already exists
out_dir = os.path.join(root_dir, 'output_1719')
if not os.path.exists(out_dir):
    os.makedirs(out_dir)

# Working on basal area files:
# Create path within root dir to find .img files for export to single gdb
ba_data_path = os.path.join(root_dir, 'raster_maps')

# Create gdb within output folder to hold exported ba rasters / create if it does not already exist
ba_gdb_path = os.path.join(out_dir, 'ba.gdb')
if not os.path.exists(ba_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'ba.gdb')

# Record start time
start_time = timeit.default_timer()
# Walk the root input path to get folder and file names
for (dirpath, dirnames, filenames) in os.walk(ba_data_path):
    if 'RasterMaps' in dirnames:
        print dirnames
        # Set path to rasters
        raster_map_group_dir = os.path.join(dirpath, dirnames[0])
        # Set input workspace so rasters can be found
        ap.env.workspace = raster_map_group_dir
        raster_list = ap.ListRasters()
        raster_count = len(raster_list)
        # Loop through raster list to export to gdb and convert from img to FGDB format
        for raster in raster_list:
            raster_path = os.path.join(ba_gdb_path, raster.replace('.img', ''))
            # Check for existence so if code is not completed in one session doesn't waste time
            # rewriting over if process restarted
            if ap.Exists(raster_path):
                print 'exists: ', raster
                pass
            else:
                ap.RasterToGeodatabase_conversion(raster, ba_gdb_path)

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print 'export to gdb took', elapsed_min, 'minutes'