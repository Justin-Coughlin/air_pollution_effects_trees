"""
#### Script Information ####

Script name: s9b_deposition_level_for_survival_reduction.py

Purpose of script: Calculate the deposition level for N or S (kg N or S/ha/yr) 
    that is needed to prevent a x% rate reduction in survival. 
    Default setting is 1% (0.01).

Placement in script series: #9a
Outputs needed from: s1_ba_export_to_single_gdb.py, s2_setzero_null.py,
    s3_ba_sum_natl_forest.py, s4_select_horn_spp_calc_proportion.py

Author: Justin G. Coughlin, M.S.
Date Created: 2020-12-20
Modified: 2023-07-02
Email: justin.coughlin@outlook.com

"""

# Import the necessary modules
import os
import timeit
import arcpy as ap

# Use math functions from spatial analyst instead of math module
from arcpy.sa import Divide, Exp, Ln, Square, Times  # use math functions from spatial analyst instead of math module
from arcpy.sa import *

# Set up environment
ap.env.overwriteOutput=True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# Set path general output directory
root_dir = <'Insert root directory to converted rasters here'> 
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)

# Set path to input proportional rasters created in s4_select_horn_spp_calc_proportion.p
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# Create output gdbs
n_rdxn_out_path = os.path.join(out_dir, 'N_survival_deposition_1_red_check.gdb')
if not ap.Exists(n_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'N_survival_deposition_1_red_check.gdb')

s_rdxn_out_path = os.path.join(out_dir, 'S_survival_deposition_1_red_check.gdb')
if not ap.Exists(s_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'S_survival_deposition_1_red_check.gdb')

# Create variable lists for looping thru
response_variables = ['survival']
elements = ['s', 'n']

# Record start time
start_time = timeit.default_timer()

# Begin the deposition level needed to prevent x% survival rate reduction calculation
for element in elements:
    spp_raster = os.path.join(out_dir, 'spp_proportion_ba.gdb')
    spp_raster2 = os.path.join(out_dir, 'spp_proportion_ba.gdb')
    # exc_path = os.path.join(out_dir, '{}_dep_net.gdb'.format(element).capitalize())
    # It only makes sense to incorporate this if you only want to look at places
    # where exceedances are occurring; you would use this as the mask; the raster
    # would need to be called
    ap.env.workspace = spp_prop_ba_gdb_path
    for response_variable in response_variables:
        spp_raster_list = ap.ListRasters('*survival*')
        # List proportional rasters for looping thru
        spp_prop_ba_raster_list = ap.ListRasters()
        for spp_raster in spp_prop_ba_raster_list:
            
            # Save names for extrapolated values output
            out_raster_name = '{0}_{1}_survival_deposition'.format(spp_raster, element)
            out_raster_save_path = os.path.join(os.path.join(out_dir, '{}_survival_deposition_1_red_check.gdb'.format(element).capitalize()), out_raster_name)
            
            # Check for existence of previously processed rasters, skip if already done
            print('Checking for existence of extrapolated raster in output', out_raster_save_path)
            if ap.Exists(out_raster_save_path):
                print('Out file name = ', out_raster_name)
                print(' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path)
                print('Going to next raster', '\n')
            else:
                print('Does not exist in output gdb, .....process raster ', spp_raster)
                spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
                print('Effects raster will be saved to : ', out_raster_save_path, '\n')
                spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
                
                # Set environments to handle differing resolutions rasters
                ap.env.cellSize = spp_raster_path
                spatial_ref = ap.Describe(spp_raster_path).spatialReference
                ap.env.outputCoordinateSystem = spatial_ref
                ap.env.snapRaster = spp_raster_path
                
                # Setting scratch wksp to memory stops intermediary output (from divide, exp, etc) from being written to current workspace
                ap.env.scratchWorkspace = 'in_memory'
                
                # Read values need for reduction eqn from tables
                spp_code = int(spp_raster.split('_')[0][1:])
                table = os.path.join(spp_prop_ba_gdb_path, '{}').format(response_variable)
                
                # Extract the species-specific values
                # Will search for n1/s1, n2/s2, min_n/min_s, max_n/max_s
                with ap.da.SearchCursor(table, ['spp_code', '{}dep_max'.format(element)]) as cursor:
                    for row in cursor:
                        if row[0] == spp_code and row[1] == 0:
                            print('Skipping ', spp_code, ', {}dep_max'.format(element), 'is null', '\n')
                        elif row[0] == spp_code and row[1] is not None:
                            if cursor.fields[1] == '{}dep_max'.format(element):
                                max_dep = row[1]
                                rasObj = ap.sa.Con(spp_raster is not None, max_dep, spp_raster)
                            inRaster = rasObj
                            inMaskData = spp_raster
                            rasObj2 = ap.sa.ExtractByMask(inRaster, inMaskData)
                
                # Read values needed to determine the deposition level, store in memory
                spp_code = int(spp_raster.split('_')[0][1:])
                table = os.path.join(spp_prop_ba_gdb_path, '{}').format(response_variable)
                
                # Extract the species-specific values
                # Will search for n1/s1, n2/s2, min_n/min_s, max_n/max_s
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element), '{}2'.format(element), '{}dep_max'.format(element), 'max_{}'.format(element)]) as cursor:
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None:
                            print('No critical load value, **skipping** ', spp_code, ', row = ', row, '\n')
                            print('----------------------')
                        elif row[0] == spp_code and row[3] is not None:
                            if cursor.fields[1] == '{}1'.format(element):
                                element1 = row[1]
                            if cursor.fields[2] == '{}2'.format(element):
                                element2 = row[2]
                            if cursor.fields[3] == '{}dep_max'.format(element):
                                max_dep = row[3]
                                print('Values for spp code,', '{}1,'.format(element), '{}2,'.format(element), '{}dep_max = '.format(element), row)
                                
                                # Begin the deposition level needed to prevent x% reduction calculation
                                print('Calculating deposition magnitude for 5% effect')
                                
                                # Right-handed side under the square root
                                divide_max_dep = Divide(rasObj2, element1)
                                ln_max_dep = Ln(divide_max_dep)
                                square_ln_max_dep = Square(ln_max_dep)

                                # Left-handed side under the square root
                                ln_response = Ln(.99) # Set to 1-x where x is the percent reduction 
                                                        # of interest, here x=0.01, so the ln() is 0.99
                                n2_squared = Square(element2)
                                multiply_element = Times(ln_response, -2)
                                multiply_element_2 = Times(multiply_element, n2_squared)
                                divide_t = Divide(multiply_element, 10) # t=10

                                # Add the two sides, square root, and tke the exponent
                                addition_min_response = divide_t + square_ln_max_dep
                                sqrt_min_response = addition_min_response ** 0.5
                                exponent_sqrt_min_response = Exp(sqrt_min_response)

                                # Final step of the calculation
                                deposition_level = Times(element1, exponent_sqrt_min_response)

                                # Save the resulting raster
                                deposition_level.save(out_raster_save_path)
                                print('***Survival deposition raster saved to***', deposition_level)
                                print('Survival deposition calculation complete', '\n')
                                print('-------------------------')

# calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print('Creating deposition level of 5% effect rasters took ', elapsed_min, 'minutes')