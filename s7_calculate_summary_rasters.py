"""
#### Script Information ####

Script name: s7_calculate_summary_rasters.py

Purpose of script: Calculate the 5th percentile of effects from all species' effects rasters
Placement in script series: #7
Previous script: s6_effects_eqn_growth/survival_noexc.py
Adjustment for TDep: Runs will be adjusted based on TDep raster years.
    I.e.,  line 83  tdep_Raster = os.path.join(out_dir, 'tdep.gdb//{}_tw_1719'.format(element))

Notes: These data were collected using funding from the U.S.
    Government. These data may be Enforcement Confidential and may not be able to be shared.

Author: Justin G. Coughlin,  M.S.
Date Created: 2020-12-10
Email: coughlin.justin@epa.gov
"""

import os
import timeit
import numpy as np
import arcpy as ap

ap.env.overwriteOutput = True
ap.CheckOutExtension("Spatial")
ap.env.parallelProcessingFactor = "100%"

# Set path general output directory
root_dir = 'D:\coughlin\NOxSOxPMREA'
out_dir = os.path.join(root_dir, 'output_1719')
aggregate_out_path = os.path.join(out_dir, 'aggregate.gdb')
if not ap.Exists(aggregate_out_path):
    ap.CreateFileGDB_management(out_dir, 'aggregate.gdb')

# Create variable lists for looping thru
response_variables = ['survival', 'growth']
elements = ['s', 'n']

# Record start time
start_time = timeit.default_timer()
print 'beginning the raster to numpy process...'

# Species reduction pathways to gdb
for response_variable in response_variables:
    for element in elements:
        rdxn_path = os.path.join(out_dir, '{}_{}_reduction.gdb'.format(element.capitalize(), response_variable))
        ap.env.workspace = rdxn_path
        rasters = ap.ListRasters()
        out_raster_name = 'percentile_5_{}_{}'.format(response_variable, element)
        out_raster_save_path = os.path.join(os.path.join(out_dir, 'aggregate.gdb'), out_raster_name)
        if ap.Exists(out_raster_save_path):
            print 'out file name = ', out_raster_name
            print ' >>> EXISTS IN OUTPUT gdb: ', out_raster_save_path
            print 'going to next raster', '\n'
        else:
            print 'does not exist in output gdb, .....process raster ', out_raster_name
            print 'redxn raster will be saved to : ', out_raster_save_path, '\n'
            print '**setting the environment including cell size, spatial ref, and snap'
            # Set environments to handle differing resolutions rasters
            # set output coordinate system
            spatial_ref = ap.SpatialReference(5070)
            ap.env.outputCoordinateSystem = spatial_ref
            ap.env.cellSize = rdxn_path
            # Set snap raster environment
            ap.env.snapRaster = rdxn_path
            arrs = []
            for raster in rasters:
                print 'converting raster to numpy for: ', raster, 'in ', rdxn_path
                arrs.append(ap.RasterToNumPyArray(raster, nodata_to_value=100000))
                # The master array
            print 'creating median raster for extent...'
            CellStat = ap.sa.CellStatistics(rasters, 'MEDIAN')
            # ---- Save the result out to a new raster ------
            print 'setting up new raster dataset...'
            lower_left = CellStat.extent.lowerLeft  # ---- needed to produce output
            cell_size = CellStat.meanCellHeight  # ---- we will use this for x and y
            print 'converting appended arrays to full stack array...'
            a = np.array(arrs)
            ma = np.ma.masked_values(a, 100000.000000)
            ma_nan = np.ma.filled(ma, np.nan)
            print 'calculating percentile including NAs...'
            percentile_5 = np.nanpercentile(ma_nan, 5, axis=0)
            print 'converting numpy to raster...'
            out_percentile = ap.NumPyArrayToRaster(percentile_5, lower_left, cell_size, cell_size)
            out_percentile.save(out_raster_save_path)
            del a, ma, ma_nan, out_percentile

# Calculate time elapsed and print
elapsed_min = (timeit.default_timer() - start_time) / 60
print 'creating survival reduction rasters took ', elapsed_min, 'minutes'