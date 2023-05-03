#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 19 14:13:29 2020

@author: jessicaruijsch

Updated on 25 April 2022 
@mikmagni vectorized functions for parallel
"""
#=================================================s=======================
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
import os 
import glob
import re
import tqdm

filePath = '/scratch/sutan101/pcrglobwb2_output/30min_kinematicwave_w5e5_start_with_s3_estimate/netcdf_daily_renamed_to_band1_and_compressed_1979-2019/monthly/'
outputPath = '/scratch/6574882/pcr_statevars/'
loc = pd.read_csv('../../data/stationLatLon.csv')
nc_sample = netCDF4.Dataset(filePath + 'monavg_band1_baseflow_dailyTotUpsAvg_output.nc')
fileName = glob.glob(filePath + '/*dailyTotUpsAvg*')

if not os.path.exists(outputPath):
	os.makedirs(outputPath)

def get_names(): 
	
	get_names.varNames = [None] * len(fileName)
	for i in range(len(fileName)):
		get_names.varNames[i] = re.search('monavg_band1_(.*)_dailyTotUpsAvg', fileName[i])
		get_names.varNames[i] = get_names.varNames[i].group(1)

def near(array,value):
	idx=(np.abs(array-value)).argmin()
	return idx
      
def get_latlon():  
	
	xin, yin = loc['lon'], loc['lat'] 		#real life lon, lat

	lon = nc_sample.variables['lon'][:]   	#netcdf lon    
	lat = nc_sample.variables['lat'][:]		#netcdf lat

	#find nearest point to desired location
	get_latlon.ix = [None] * len(xin)
	get_latlon.iy = [None] * len(yin)
	
	for i in range(len(xin)):
		get_latlon.ix[i] = near(lon, xin[i])
		get_latlon.iy[i] = near(lat, yin[i])

def read_write_statevars(station):	
	
	statevar_matrix = []
	#read statevars and write to pd.dataframe
	for i in range(len(fileName)):

		nc = netCDF4.Dataset(fileName[i])
		var = nc.variables['band1']
        
        #find nearest point to desired location
		ix = get_latlon.ix[station]
		iy = get_latlon.iy[station]
        
		statevar_matrix.append(np.ma.getdata(var[:,iy,ix]))
		
	data = np.array(statevar_matrix)
	upstream = pd.DataFrame(data).T
	upstream.columns=get_names.varNames
	
				
	#write to csv
	upstream['datetime'] = pd.date_range(start='1/1/1979', end='12/31/2019', freq='MS')  #monthly
    
	datetime = upstream['datetime']
	upstream.drop(labels=['datetime'], axis=1,inplace = True)
	upstream.insert(0, 'datetime', datetime)
    
        # relocate meteo input variables at the beginning of the table
	precipitation = upstream['precipitation']
	upstream.drop(labels=['precipitation'], axis=1,inplace = True)
	upstream.insert(1, 'precipitation', precipitation)

	temperature = upstream['temperature']
	upstream.drop(labels=['temperature'], axis=1,inplace = True)
	upstream.insert(2, 'temperature', temperature)
	
	refPotET = upstream['referencePotET']
	upstream.drop(labels=['referencePotET'], axis=1,inplace = True)
	upstream.insert(3, 'referencePotET', refPotET)
	
	# read station number and save to disk
	station_no = str(loc['grdc_no'][station])
	upstream.to_csv(outputPath+'pcr_statevars_'+station_no+'.csv', index=False)
	

get_latlon()
get_names()

station_idx = np.array(range(len(loc))) #set vector of indexes
pool = Pool(processes=36) # set number of cores

for _ in tqdm.tqdm(pool.imap_unordered(read_write_statevars, station_idx), total=len(station_idx)):
	pass
