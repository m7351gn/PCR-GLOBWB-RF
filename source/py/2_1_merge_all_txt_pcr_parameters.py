# !/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

@author: mikmagni 11-6-2022 00:42

"""
#========================================================================
#
#   Merge all tables of parameters into one (both normalized and non-normalized)
#	Note: these are static predictors (same value for the whole timeseries).
# 
#
#======================================================================== 

import pandas as pd
import os 
import numpy as np
import re


#normalized map files
filePath = '../../data/preprocess/pcr_parameter_maps_upstream_txt_normalized/'
parameterList = os.listdir(filePath)
outputPath = '../../data/' 

# read all files and attach next to each other
df = pd.read_csv((filePath + parameterList[0]))
df = df.drop(['value'], axis=1)

indexes_vector = pd.array(np.arange(0, len(df)))
df.insert(loc=0, column='grdc_no', value=indexes_vector)


for i in range(len(parameterList)):
	
	varName = re.search('upstream_norm_(.*).txt', parameterList[i])
	varName = varName.group(1)
	print(varName)
	
	#open file
	df_to_join = pd.read_csv((filePath + parameterList[i]))

	df_to_join.columns = ['lon','lat',varName]

        #join by lat lon 
	df = pd.merge(df, df_to_join, how='left').fillna(method='bfill')

# save to file
df.to_csv((outputPath + 'allpoints_catchAttr_normalized.csv') , index=False)




#non-normalized map files
filePath = '../../data/preprocess/pcr_parameter_maps_upstream_txt/'
parameterList = os.listdir(filePath)
outputPath = '../../data/' 

# read all files and attach next to each other
df = pd.read_csv((filePath + parameterList[0]), delim_whitespace=True, header=None)
df.columns = ['lon', 'lat', 'value']
df = df.drop(['value'], axis=1)

indexes_vector = pd.array(np.arange(0, len(df)))
df.insert(loc=0, column='grdc_no', value=indexes_vector)


for i in range(len(parameterList)):
	
	varName = re.search('upstream_(.*).txt', parameterList[i])
	varName = varName.group(1)
	print(varName)
	
	#open file
	df_to_join = pd.read_csv((filePath + parameterList[i]), delim_whitespace=True, header=None)

	df_to_join.columns = ['lon','lat',varName]

        #join by lat lon 
	df = pd.merge(df, df_to_join, how='left').fillna(method='bfill')

# save to file
df.to_csv((outputPath + 'allpoints_catchAttr_raw.csv') , index=False)
