"""
#### Script Information ####

Script name: s5_calculate_wilson_exceedance.py

Purpose of script: Calculate where Horn species are in exceedance 
    based on their n1 value (critical load)

Placement in script series: #5
Outputs needed from: s1_ba_export_to_single_gdb.py, s2_setzero_null.py, 
    s3_ba_sum_natl_forest.py, s4_select_horn_spp_calc_proportion.py
Adjustment for TDep: Runs will be adjusted based on TDep raster years. Change suffix where necessary.
    I.e.,  line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_1719'.format(element))

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
ap.CheckOutExtension("Data Access")
ap.env.parallelProcessingFactor = "100%" # Parallel processing assists in the speed

# Set path general output directory
root_dir = <'Insert root directory to converted rasters here'>
out_dir = os.path.join(root_dir, <'Insert folder directory here'>)

# Set path to input proportional rasters gdb created in #3: select_horn_spp_calc_proportion
spp_prop_ba_gdb_path = os.path.join(out_dir, 'spp_proportion_ba.gdb')

# Set scratch workspace to hold intermediary calculated rasters
scratch_gdb_path = os.path.join(out_dir, 'Scratch.gdb')
if not ap.Exists(scratch_gdb_path):
    ap.CreateFileGDB_management(out_dir, 'Scratch.gdb')

# Import tree characteristic tables for growth into input proportional rasters gdb
growthTable = os.path.join(root_dir, 'growth.csv')
growth_table_path = os.path.join(spp_prop_ba_gdb_path, growthTable)
growth_table_check_path = os.path.join(spp_prop_ba_gdb_path, 'growth')
if not ap.Exists(growth_table_check_path): # Create the directory if it does not exist
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=spp_prop_ba_gdb_path)

# Import tree characteristic tables for survival into input proportional rasters gdb
survivalTable = os.path.join(root_dir, 'survival.csv')
survival_table_path = os.path.join(spp_prop_ba_gdb_path, survivalTable)
survival_table_check_path = os.path.join(spp_prop_ba_gdb_path, 'survival')
if not ap.Exists(survival_table_check_path): # Create the directory if it does not exist
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=spp_prop_ba_gdb_path)

# Create output gdbs
# Additionally import tdep values tables into output gdbs in preparation for next step: reduction calculations
n_out_path = os.path.join(out_dir, 'N_dep_1719.gdb')
if not ap.Exists(n_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'N_dep_1719.gdb')
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=n_out_path)
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=n_out_path)

s_out_path = os.path.join(out_dir, 'S_dep_1719.gdb')
if not ap.Exists(s_out_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'S_dep_1719.gdb')
    ap.TableToGeodatabase_conversion(Input_Table=growthTable, Output_Geodatabase=s_out_path)
    ap.TableToGeodatabase_conversion(Input_Table=survivalTable, Output_Geodatabase=s_out_path)

# Import tdep rasters from source folders into a single gdb
# Create output gdb for exported tdep rasters / if tdep gdb does not exist create it
tdep_gdb_path = os.path.join(out_dir, 'tdep.gdb')
if not ap.Exists(tdep_gdb_path): # Create the directory if it does not exist
    ap.CreateFileGDB_management(out_dir, 'tdep.gdb')

# Record start time
start_time = timeit.default_timer()

# Create variable lists for looping thru
response_variables = ['growth', 'survival']
elements = ['n', 's']

# Set tdep raster paths n_tw_1719 or s_tw_1719 [e.g., 2000-2002 run] - currently se for 17-19
for element in elements:
    # path to tdep raster
    tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_1719'.format(element)) # Assumes tdep gdb name is tdep.gdb
    for response_variable in response_variables:
        # Set input workspace so arcpy can find proportional rassters
        ap.env.workspace = spp_prop_ba_gdb_path
        # Set save paths (will be either of the S_dep or N_dep geodatabases created above)
        gdb_save_path = os.path.join(out_dir, '{}'.format(element).capitalize() + '_dep_1719.gdb')

        # List proportional rasters for looping through
        spp_prop_ba_raster_list = ap.ListRasters()
        for spp_raster in spp_prop_ba_raster_list:
            # Create save names and save paths for raster so can check if already exists in output gdb;
            # Skip if already done
            out_raster_name = '{0}_exc_{1}_{2}_1719'.format(spp_raster, element, response_variable)
            out_raster_save_path = os.path.join(gdb_save_path, out_raster_name)
            ap.env.scratchWorkspace = os.path.join(out_dir, 'Scratch.gdb')
            print('**Check**: element, response variables match for in and out file names:',\
                out_raster_name + ':', element, response_variable)
            if ap.Exists(out_raster_save_path):
                print('Out file name = ', out_raster_name)
                print(' >>> EXISTS IN OUTPUT EXCEEDANCE gdb, go to next raster', '\n')
                pass
            else:
                print('Does not exist in output gdb, process raster ', spp_raster)
                print('Exceedance raster will be saved to : ', out_raster_save_path, '\n')
                # Create path to proportional raster
                spp_raster_path = os.path.join(spp_prop_ba_gdb_path, spp_raster)
                # Set environments to handle differing resolutions rasters
                # Set the cell size environment using a raster dataset
                ap.env.cellSize = spp_raster_path
                # set output coordinate system
                spatial_ref = ap.Describe(spp_raster_path).spatialReference
                ap.env.outputCoordinateSystem = spatial_ref
                # Set snap raster environment
                ap.env.snapRaster = spp_raster_path
                inTrueRaster = spp_raster
                inFalseConstant = 0
                spp_code = int(spp_raster.split('_')[0][1:])
                # Set path to tdep value table to iterate thru values below
                table = os.path.join(spp_prop_ba_gdb_path, '{}').format(response_variable)
                # Use Cursor to access each row within fields
                with ap.da.SearchCursor(table, ['spp_code', '{}1'.format(element)]) as cursor:
                    print('Checking for critical load values...')
                    for row in cursor:
                        if row[0] == spp_code and row[1] is None:
                            # Skipping over species with flat responses, ie no values in n1 or s1
                            print('No critical load value, skipping ', spp_raster, ', row = ', row, '\n')
                            print('-----------------------')
                        elif row[0] == spp_code and row[1] is not None:
                            print('Found critical load value, calculating exceedance raster...')
                            # 'row' is a tuple, and looks like this, for e.g. for species # 121: (121, 12.32753)
                            whereClause = "VALUE >={}".format(row[1])
                            # 'Value' is pulled from the second number in row, that comes from the table,
                            # Value for n1 or s1
                            outCon = ap.sa.Con(tdep_Raster, inTrueRaster, inFalseConstant, whereClause)
                            # Set non-exceedances to null 
                            inTrueRaster2 = outCon
                            inFalseRaster = outCon
                            whereClause2 = "VALUE = 0" 
                            outSetNull = ap.sa.SetNull(inTrueRaster2, inFalseRaster, whereClause2)
                            outSetNull.save(os.path.join(out_raster_save_path))
                            print('***EXCEEDANCE saved to***', out_raster_save_path, '\n')

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time)/60
print('Creating exceedence for proportional rasters', elapsed_min, 'minutes')
