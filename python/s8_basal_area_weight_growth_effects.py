"""
#### Script Information ####

Script name: s8_basal_area_weight_growth_effects.py

Purpose of script: Calculate the weighted basal area effect using the proportional basal area
    and the effects raster

Placement in script series: #8
Outputs needed from: s1_ba_export_to_single_gdb.py, s2_setzero_null.py, 
    s3_ba_sum_natl_forest.py, s4_select_horn_spp_calc_proportion.py,
    s6a_effects_eqn_growth.py or s6b_eqn_survival.py
Adjustment for TDep: Runs will be adjusted based on TDep raster years. Change suffix where necessary.
    I.e.,  line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))

Note: This script is burdensome on RAM usage. A minimum of 64 GB RAM is needed for to run this script.
    If that amount of RAM s unavailable, tiling can be done within the script then mosaicked back together.
    A tiling/mosaic code chunk is not currently contained within the script.

Author: Justin G. Coughlin, M.S.
Date Created: 2020-12-10
Modified: 2023-07-02
Email: justin.coughlin@outlook.com

"""

import os
import timeit

import arcpy as ap

# Use math functions from spatial analyst instead of math module
from arcpy.sa import Divide, Exp, Ln, Square, Times

# Set up environment
ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# Set path general output directory
root_dir = <'Insert root directory to converted rasters here'> 
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)

# Set path to input proportional rasters created in s4_select_horn_spp_calc_proportion.py
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# Create output gdbs
n_spp_rdxn_path = os.path.join(out_dir, 'N_growth_effect.gdb')
s_spp_rdxn_path = os.path.join(out_dir, 'S_growth_effect.gdb')
n_spp_rdxn_path = os.path.join(out_dir, 'N_survival_effect.gdb')
s_spp_rdxn_path = os.path.join(out_dir, 'S_survival_effect.gdb')

# Create variable lists for looping thru
response_variables = ['growth']
elements = ['s', 'n']

# Create output gdbs
n_rdxn_out_path = os.path.join(out_dir, 'N_basal_area_prop_growth_effect.gdb')
if not ap.Exists(n_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'N_basal_area_prop_growth_effect.gdb')

s_rdxn_out_path = os.path.join(out_dir, 'S_basal_area_prop_growth_effect.gdb')
if not ap.Exists(s_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'S_basal_area_prop_growth_effect.gdb')

# Record start time
start_time = timeit.default_timer()

# Begin the basal area weighted effect calculation
for response_variable in response_variables:
    for element in elements:
        spp_rdxn_path = os.path.join(out_dir, '{}_{}_effect.gdb'.format(element.capitalize(), response_variable))
        rdxn_raster = os.path.join(out_dir, spp_rdxn_path)
        ap.env.workspace = spp_rdxn_path
        rdxn_raster_list = ap.ListRasters()
        for rdxn_raster in rdxn_raster_list:
            spp_code_rdxn = int(rdxn_raster.split('_')[0][1:])
            print('**Check**: element, response variables match for in and out file names:', \
                rdxn_raster + ':', element)
           
            # Create save names and save paths for raster so can check for existence
            out_raster_name = '{0}_basalarea'.format(rdxn_raster)
            out_raster_save_path = os.path.join(os.path.join(out_dir, '{}_basal_area_prop_{}_effect.gdb'.
                                                            format(element.capitalize(), response_variable), \
                                                            out_raster_name))
            
            # Check for existence of previously processed rasters, skip if already done
            if ap.Exists(out_raster_save_path):
                print('Out file name = ', out_raster_name)
                print(' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path)
                print('Going to next raster', '\n')
            else:
                print('Does not exist in output gdb, .....process raster ', rdxn_raster)
                print('Redxn raster will be saved to : ', out_raster_save_path, '\n')
                
                # Set environments to handle differing resolutions raster
                print('**Setting the environment including cell size, spatial ref, and snap')
                workspaces = [spp_prop_ba_gdb_path, spp_rdxn_path]
                for ws in workspaces:
                    effect = rdxn_raster
                    spp_raster = os.path.join(out_dir, spp_prop_ba_gdb_path)
                    spp_raster_list = ap.ListRasters()
                    for spp_raster in spp_raster_list:
                        spp_code = int(spp_raster.split('_')[0][1:])
                        ba = spp_raster
                        if spp_code_rdxn == spp_code:
                            print('Running basal area proportion effect for:', out_raster_name)
                            ba_wt_rdxn = Times(ba, effect) # Multiply the effect raster against the basal area proportion 
                            ba_wt_rdxn.save(out_raster_save_path)


# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print('Creating basal area weighted growth effect rasters took ', elapsed_min, 'minutes')