#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 19 14:13:29 2020

@author: jessicaruijsch

Updated on 11 June 2022 
@mikmagni: vectorized functions for parallel
"""
#========================================================================
#
# * This script extracts values from all netCDF files in a folder and 
#   outputs the values as a csv file. 
# * The values at different locations are saved in different csv files 
#   in the output file path, with location names indicated at the end of the file names.
#
#========================================================================

from multiprocessing import Pool
import xarray as xr
import pandas as pd
import netCDF4
import numpy as np
from os import listdir
import os,fnmatch
import tqdm

filePath = '/scratch/sutan101/pcrglobwb2_output/30min_kinematicwave_w5e5_start_with_s3_estimate/netcdf_daily_renamed_to_band1_and_compressed_1979-2019/monthly/'
outputPath = '/scratch/6574882/pcr_discharge' 
loc = pd.read_csv('../../data/stationLatLon.csv')
file_name = "monavg_band1_discharge_dailyTot_output.nc" #file containing discharge
nc = netCDF4.Dataset(filePath+file_name)

if not os.path.exists(outputPath):
    os.makedirs(outputPath)

def near(array,value):
    idx=(np.abs(array-value)).argmin()
    return idx
    
def get_latlon():  
	
	xin, yin = loc['lon'], loc['lat'] 		#real life lon, lat

	lon = nc.variables['lon'][:]   	#netcdf lon    
	lat = nc.variables['lat'][:]		#netcdf lat

	#find nearest point to desired location
	get_latlon.ix = [None] * len(xin)
	get_latlon.iy = [None] * len(yin)
	
	for i in range(len(xin)):
		get_latlon.ix[i] = near(lon, xin[i])
		get_latlon.iy[i] = near(lat, yin[i])
		    
def get_discharge(station):

	lon = nc.variables['lon'][:]
	lat = nc.variables['lat'][:]
	var = nc.variables['band1']
	
    # find nearest point to desired location
	ix = get_latlon.ix[station]
	iy = get_latlon.iy[station]
	
	# PCR-GLOBWB was run for 1979-2019 (select dates in pd.date_range)	
	upstream = pd.DataFrame(var[:,iy,ix],columns=['pcr']) #latitude comes before longitude in PCR-GLOBWB netCDF file)
	upstream['datetime'] = pd.date_range(start='1/1/1979', end='12/31/2019', freq='MS') #monthly
	
	datetime = upstream['datetime']
	upstream.drop(labels=['datetime'], axis=1,inplace = True)
	upstream.insert(0, 'datetime', datetime)
    
	station_no = str(loc['grdc_no'][station])
	upstream.to_csv(outputPath+'/pcr_discharge_'+station_no+'.csv', index=False, float_format='%.3f')


get_latlon()

station_idx = np.array(range(len(loc))) #set vector of indexes
pool = Pool(processes=36) # set number of cores

for _ in tqdm.tqdm(pool.imap_unordered(get_discharge, station_idx), total=len(station_idx)):
	pass
