"""
#### Script Information ####

Script name: s8_basal_area_weight_growth_effects.py

Purpose of script: Calculate basal-area weighted amount of reductions in growth
Placement in script series: #8
Previous script: s7_calculate_summary_rasters.py

Notes: These data were collected using funding from the U.S.
    Government. These data may be Enforcement Confidential and may not be able to be shared.

Author: Justin G. Coughlin,  M.S.
Date Created: 2020-12-20
Email: coughlin.justin@epa.gov
"""

import os
import timeit

import arcpy as ap

# Use math functions from spatial analyst instead of math module
from arcpy.sa import Divide, Exp, Ln, Square, Times

ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# Set path general output directory
root_dir = 'D:\coughlin\NOxSOxPMREA'
out_dir = os.path.join(root_dir, 'output_1719')

# Set path to input proportional rasters created in #3
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# Create output gdbs
n_spp_rdxn_path = os.path.join(out_dir, 'N_growth_reduction.gdb')

s_spp_rdxn_path = os.path.join(out_dir, 'S_growth_reduction.gdb')

# Create output gdbs
n_rdxn_out_path = os.path.join(out_dir, 'N_basal_area_prop_growth_reduction.gdb')
if not ap.Exists(n_rdxn_out_path):
    ap.CreateFileGDB_management(out_dir, 'N_basal_area_prop_growth_reduction.gdb')

s_rdxn_out_path = os.path.join(out_dir, 'S_basal_area_prop_growth_reduction.gdb')
if not ap.Exists(s_rdxn_out_path):
    ap.CreateFileGDB_management(out_dir, 'S_basal_area_prop_growth_reduction.gdb')

# Create variable lists for looping thru
response_variables = ['growth']
elements = ['s', 'n']

# Record start time
start_time = timeit.default_timer()

for element in elements:
    spp_rdxn_path = os.path.join(out_dir, '{}_growth_reduction.gdb'.format(element).capitalize())
    rdxn_raster = os.path.join(out_dir, spp_rdxn_path)
    ap.env.workspace = spp_rdxn_path
    rdxn_raster_list = ap.ListRasters()
    for rdxn_raster in rdxn_raster_list:
        spp_code_rdxn = int(rdxn_raster.split('_')[0][1:])
        print '**check**: element, response variables match for in and out file names:', \
            rdxn_raster + ':', element
        # Create save names and save paths for raster so can check for existence
        out_raster_name = '{0}_basalarea'.format(rdxn_raster)
        out_raster_save_path = os.path.join(os.path.join(out_dir, '{}_basal_area_prop_growth_reduction.gdb'.
                                                         format(element).capitalize()), out_raster_name)
        # Check for existence of previously processed rasters, skip if already done
        if ap.Exists(out_raster_save_path):
            print 'out file name = ', out_raster_name
            print ' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path
            print 'going to next raster', '\n'
        else:
            print 'does not exist in output gdb, .....process raster ', rdxn_raster
            print 'redxn raster will be saved to : ', out_raster_save_path, '\n'
            print '**setting the environment including cell size, spatial ref, and snap'
            # Set environments to handle differing resolutions raster
            workspaces = [spp_prop_ba_gdb_path, spp_rdxn_path]
            for ws in workspaces:
                effect = rdxn_raster
                spp_raster = os.path.join(out_dir, spp_prop_ba_gdb_path)
                spp_raster_list = ap.ListRasters()
                for spp_raster in spp_raster_list:
                    spp_code = int(spp_raster.split('_')[0][1:])
                    ba = spp_raster
                    if spp_code_rdxn == spp_code:
                        print 'running basal area proportion effect for:', out_raster_name
                        ba_wt_rdxn = Times(ba, effect)
                        ba_wt_rdxn.save(out_raster_save_path)


# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print 'creating basal area weighted growth reduction rasters took ', elapsed_min, 'minutes'
