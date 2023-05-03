# !/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

@author: mikmagni

"""
#========================================================================
#
#   This script extracts grdc time series (daily scale)
#   based on grdc station number        
# 
#
#======================================================================== 

import pandas as pd
import os 
import numpy as np
from alive_progress import alive_bar
import time

filePath = '/scratch/6574882/grdc_discharge_daily_complete_2022/'
outputPath = '../../data/preprocess/grdc_discharge_daily/'
loc = pd.read_csv('../../data/stationLatLon_daily.csv')

if not os.path.exists(outputPath):
	os.makedirs(outputPath)

with alive_bar(len(loc), force_tty=True) as bar:	
	
	for j in range(len(loc)):
		
		station_no = str(loc['grdc_no'][j])
		# ~ station_name = loc['station'][j].lower()    
		# ~ print(station_no, ':', station_name)

		# read discharge, values start from line 38 of .txt files idx[37]
		grdc_discharge = open(filePath + station_no + '_Q_Day.Cmd.txt', encoding= 'unicode_escape')
		lines = grdc_discharge.readlines()
		
		df = pd.DataFrame(lines[37:])
		
		df = df[0].str.split(pat=' ', n=1, expand=True)
		datetime = df[0].str.split(pat=';', n=1, expand = True)

		df.columns=['datetime','obs']
		
		df['datetime'] = datetime[0]
		df['datetime'] = pd.to_datetime(df['datetime'])
		df['obs'] = pd.to_numeric(df['obs'])
	
		df.to_csv(outputPath+'grdc_daily_'+station_no+'.csv', index=False, float_format='%.3f')
		
		bar()
