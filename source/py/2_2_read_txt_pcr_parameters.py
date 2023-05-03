# !/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

@author: mikmagni

"""
#========================================================================
#
#   This script extracts catchment attributes and updates them to stationLatLon.csv       
# 
#
#======================================================================== 

import pandas as pd
import os 
import numpy as np
from alive_progress import alive_bar
import re

loc = pd.read_csv('../../data/stationLatLon.csv')
catchAttrTable = pd.read_csv('../../data/allpoints_catchAttr_normalized.csv')

def near(array,value):
    idx=(np.abs(array-value)).argmin()
    return idx

# parameter extraction and attach to stationLatLon.csv

with alive_bar(len(loc), force_tty=True) as bar:
	
	catchAttributes = []
	
	for j in range(len(loc)):

		station_no = str(loc['grdc_no'][j])
		xin, yin = loc['lon'][j], loc['lat'][j]
		
		ix = near(catchAttrTable['lon'], xin)
		iy = near(catchAttrTable['lat'], yin)
		
		iLon = catchAttrTable['lon'][ix]
		iLat = catchAttrTable['lat'][iy]

		# find closest PCR-GLOBWB pixel based on lon & lat
		value = np.array(catchAttrTable.loc[(catchAttrTable['lon']==iLon) & (catchAttrTable['lat']==iLat)])
		
		# append to list containing attributes of one station
		catchAttributes.append(value)
		
		bar()
		
# attach catchAttributes to stationLatLon.csv, name attributes and save to disk
attributesdf = pd.DataFrame(np.concatenate(catchAttributes))
attributesdf.columns = catchAttrTable.columns
attributesdf = attributesdf.loc[:, 'airEntry1':'tanSlope']
attributesdf.rename(columns={'area':'area_pcr'}, inplace=True)

updated_table = loc.join(attributesdf)
updated_table.to_csv('../../data/stationLatLon_catchAttr.csv', index=False)
