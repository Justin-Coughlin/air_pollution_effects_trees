"""
#### Script Information ####

Script name: s4_select_horn_spp_calc_proportion.py

Purpose of script: Determine the indvidual Horn species proportion of basal area to the national forest basal area
Placement in script series: #4
Previous script: s3_ba_sum_natl_forest.py

Notes: These data were collected using funding from the U.S.
    Government. These data may be Enforcement Confidential and may not be able to be shared.

Author: Justin G. Coughlin,  M.S.
Date Created: 2020-12-10
Email: coughlin.justin@epa.gov
"""

import os
import timeit

import arcpy as ap

ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

horn_spp_code_num_list = [11, 12, 15, 17, 19, 64, 65, 68, 69, 71, 73, 81, 93, 94, 95, 97, 105, 106, 108,
                          110, 111, 121, 122, 125, 126, 129, 131, 132, 133, 202, 221, 222, 241, 242,
                          261, 263, 264, 313, 316, 317, 318, 371, 372, 375, 391, 402, 403, 407, 408,
                          409, 461, 462, 531, 541, 543, 544, 552, 602, 611, 621, 631, 641, 653, 691,
                          693, 694, 701, 711, 731, 741, 743, 746, 762, 802, 805, 806, 809, 812, 820,
                          823, 826, 827, 831, 832, 833, 835, 837, 901, 922, 931, 951, 971, 972, 975]

# Create list for horn species codes to extract only these from raster source folder
horn_spp_code_list = map(str, horn_spp_code_num_list)
horn_spp_code_list = ['s' + horn_spp_code for horn_spp_code in horn_spp_code_list]
horn_spp_code_list_length = len(horn_spp_code_list)

# Direct paths to root directory and output directory
root_dir = ('D:\coughlin\NOxSOxPMREA')
out_dir = os.path.join(root_dir, 'output_1719')
ba_gdb_path = os.path.join(out_dir, 'ba_null.gdb')

# Path to output for proportional calculations; if gdb does not exist then create it
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')
if not ap.Exists(spp_prop_ba_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'spp_proportion_ba.gdb')

# Set input workspace so ArcPy can find basal area rasters
ap.env.workspace = ba_gdb_path

# Set path for ba national raster
ba_natl_raster = ap.ListRasters('ba_null_natl_forest')[0]
# create list of all ba raster for all species
ba_spp_raster_list = ap.ListRasters('s*')

# Record start time
start_time = timeit.default_timer()

counter = 0
for ba_spp_raster in ba_spp_raster_list:
    if ba_spp_raster in horn_spp_code_list:  # Limit processing to Horn species rasters
        print ba_spp_raster
        # Perform division: horn raster / national ba raster
        out_divide = ap.sa.Divide(ba_spp_raster, ba_natl_raster)
        # Save output with species' name
        out_divide_raster_name = '{}_proportion'.format(ba_spp_raster)
        print 'working on division for:  ', out_divide_raster_name
        out_divide_save_path = os.path.join(spp_prop_ba_gdb_path, out_divide_raster_name)
        print '***SAVING***  ', out_divide_raster_name, 'as ', out_divide_save_path
        out_divide.save(out_divide_save_path)
        counter += 1

if counter != horn_spp_code_list_length:
    print '***full list horn species not calc\'d***', 'check-', 'only', counter, 'spp processed, should be 94 total'

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print 'calculating proportion and saving to gdb took ', elapsed_min, 'minutes'
