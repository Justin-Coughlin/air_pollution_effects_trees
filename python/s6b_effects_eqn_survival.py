"""
#### Script Information ####

Script name: s5_effect_eqn_survival.py

Purpose of script: Calculate Horns species effects of survival rates not based on CL exceedances
Placement in script series: #6
Previous script: s4_select_horn_spp_calc_proportion.py
Adjustment for TDep: Runs will be adjusted based on TDep raster years.
    I.e.,  line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_0002'.format(element))

Notes: These data were collected using funding from the U.S.
    Government. These data may be Enforcement Confidential and may not be able to be shared.

Author: Justin G. Coughlin,  M.S.
Date Created: 2020-12-10
Email: coughlin.justin@epa.gov
"""

# Import the necessary modules
import os
import timeit
import arcpy as ap

# Use math functions from spatial analyst instead of math module
from arcpy.sa import Divide, Exp, Ln, Square, Times

# Set up environment
ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%" # Parallel processing assists in the speed

# Set path general output directory
root_dir = <'Insert root directory to converted rasters here'>
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)

# Set path to input proportional rasters created in s4_select_horn_spp_calc_proportion.py
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# Import tree characteristic tables for survival into input proportional rasters gdb
survivalTable = os.path.join(root_dir, 'survival.csv')
survival_table_path = os.path.join(spp_prop_ba_gdb_path, survivalTable)
survival_table_check_path = os.path.join(spp_prop_ba_gdb_path, 'survival')
if not ap.Exists(survival_table_check_path): # Create the directory if it does not exist
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=spp_prop_ba_gdb_path)

# Create output gdbs
n_rdxn_out_path = os.path.join(out_dir, 'N_survival_effect.gdb')
if not ap.Exists(n_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'N_survival_effect.gdb')

s_rdxn_out_path = os.path.join(out_dir, 'S_survival_effect.gdb')
if not ap.Exists(s_rdxn_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'S_survival_effect.gdb')

# Create variable lists for looping thru
response_variables = ['survival']
elements = ['s', 'n']

# Record start time
start_time = timeit.default_timer()

# Begin the survival rate effect loop
for element in elements:
    spp_raster = os.path.join(out_dir, 'spp_proportion_ba.gdb')  # Walk proportion basal area raster path
    tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_1719'.format(element)) # Walk TDep raster path, currently set to 1719
    ap.env.workspace = spp_prop_ba_gdb_path
    for response_variable in response_variables:
        spp_raster_list = ap.ListRasters()
        for spp_raster in spp_raster_list:
            print('**Check**: element, response variables match for in and out file names:', \
                spp_raster + ':', element, response_variable)
            # Create save names and save paths for raster so can check for existence
            out_raster_name = '{0}_effect'.format(spp_raster)
            out_raster_save_path = os.path.join(os.path.join(out_dir, '{}_survival_effect.gdb'.
                                                             format(element).capitalize()), out_raster_name)
            # Check for existence of previously processed rasters, skip if already done
            if ap.Exists(out_raster_save_path):
                print('Out file name = ', out_raster_name)
                print(' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path)
                print('Going to next raster', '\n')
            else:
                print('Does not exist in output gdb, .....process raster ', spp_raster)
                spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
                print('Redxn raster will be saved to : ', out_raster_save_path, '\n')
                # Test if spp raster has exceedance values, if not pass
                print('**Setting the environment including cell size, spatial ref, and snap')
                # Extract tdep raster values where spp in exceedance
                
                # Set environments to handle differing resolutions rasters
                ap.env.cellSize = spp_raster_path
                spatial_ref = ap.Describe(spp_raster_path).spatialReference
                ap.env.outputCoordinateSystem = spatial_ref
                ap.env.snapRaster = spp_raster_path
                ap.env.scratchWorkspace = 'in_memory'
                
                # Read values need for effect eqn from tables
                spp_code = int(spp_raster.split('_')[0][1:])
                table = os.path.join(spp_prop_ba_gdb_path, '{}').format(response_variable)
                inTrueRaster = tdep_Raster
                inFalseRaster = tdep_Raster

                # Extract the species-specific values
                # Will search for n1/s1, n2/s2, min_n/min_s, max_n/max_s
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element), '{}2'.format(element), 'min_{}'.format(element), 'max_{}'.format(element)]) as cursor:
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None:
                            print('No critical load value, **skipping** ', spp_code, ', row = ', row, '\n')
                            print('----------------------')
                        # Masking any locations where the deposition is outside the domain of the response curve
                        elif row[0] == spp_code and row[1] is not None:
                            print('Found critical load value, processing ', spp_code, ', row = ', row, '\n')
                            whereClause = (("VALUE <{}".format(row[3]))) or (("VALUE >{}".format(row[4])))
                            rasObj = ap.sa.SetNull(inTrueRaster, inFalseRaster, whereClause)
                            inRaster = rasObj
                            inMaskData = spp_raster # Use the species basal area raster as a way to mask the species' range
                            rasObj2 = ap.sa.ExtractByMask(inRaster, inMaskData)
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element), '{}2'.format(element),
                                                'min_{}'.format(element), '{}dep_max'.format(element),
                                                'max_{}'.format(element)]) as cursor:
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None:
                            print('No critical load value, **skipping** ', spp_code, ', row = ', row, '\n')
                            print('----------------------')
                        elif row[0] == spp_code and row[3] is not None:
                            if cursor.fields[1] == '{}1'.format(element):
                                element1 = row[1]
                            if cursor.fields[2] == '{}2'.format(element):
                                element2 = row[2]
                            if cursor.fields[3] == 'min_{}'.format(element):
                                min_dep = row[3]
                            if cursor.fields[4] == '{}dep_max'.format(element):
                                dep_max = row[4]
                                # If dep_max is NA (nitrogen-survival species), then call min_dep for eqns instead
                                if dep_max is None:
                                    dep_max = row[3]
                                print('Values for spp code,', '{}1,'.format(element), '{}2,'.format(element), \
                                    '{}dep_max,'.format(element), 'min_{} = '.format(element), row)

                                # Numerator survival effect
                                print('Calculating numerator')
                                dep_div_element1 = Divide(rasObj2, element1)
                                ln_dep_div_element1 = Ln(dep_div_element1)
                                ln_dep_div_element1_div_element2 = Divide(ln_dep_div_element1, element2)
                                sq_ln_dep_div_element1_div_element2 = Square(ln_dep_div_element1_div_element2)
                                e_exp_numerator = Times(sq_ln_dep_div_element1_div_element2, -5.0)
                                numerator_survival = Exp(e_exp_numerator)  
                                print('Numerator_survival: ', numerator_survival)
                                
                                # Denominator growth effect
                                print('Calculating denominator')
                                # Con equation to check if dep value is above dep_max to only reference dep_max
                                # if above or min_dep if dep value is below, if cursor for dep_max = NA applies here
                                dep_div_element1 = ap.sa.Con(rasObj2 > dep_max,
                                                             Divide(dep_max, element1), Divide(min_dep, element1))
                                ln_dep_div_element1 = Ln(dep_div_element1)
                                ln_dep_div_element1_div_element2 = Divide(ln_dep_div_element1, element2)
                                sq_ln_dep_div_element1_div_element2 = Square(ln_dep_div_element1_div_element2)
                                e_exp_denominator = Times(sq_ln_dep_div_element1_div_element2, -5.0)
                                denominator_survival = Exp(e_exp_denominator)
                                print('Denominator_survival: ', denominator_survival)

                                # Percent effect raster calculation
                                print('Calculating survival effect percentage raster')
                                effect_survival = (Divide(numerator_survival, denominator_survival))
                                final_effect = effect_survival - 1
                                final_effect.save(out_raster_save_path)

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print('Creating survival effect rasters took ', elapsed_min, 'minutes')

