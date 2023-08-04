# PCR-GLOBWB-RF

## Introduction
Models are characterized by uncertainty in their components, which can be corrected with a variety of methodologies.
We correct streamflow simulations from the global hydrological model PCR-GLOBWB 2 ([Sutanudjaja et al., 2018](https://doi.org/10.5194/gmd-11-2429-2018)) using Random Forests Regression ([Breiman, 2001](https://doi.org/10.1023/A:1010933404324)), for the years 1979-2019.
In addition to meteorological input and catchment attributes, we use hydrological state variables from PCR-GLOBWB 2 as predictors of observed discharge (response variable).
This framework is an update of the method by [Shen et al. (2022)](https://doi.org/10.1016/j.cageo.2021.105019) to the global scale. Details can be found in the [paper]( 
https://doi.org/10.2166/hydro.2023.217).


## Input data
Input data and outputs of the 30 arcmin run are available on Zenodo ([input](https://doi.org/10.5281/zenodo.7890583), [output](https://doi.org/10.5281/zenodo.7891352), [validation hydrographs](https://doi.org/10.5281/zenodo.7893903)). \
River discharge data was downloaded from the Global Runoff Data Centre ([GRDC](https://www.bafg.de/GRDC)). \
2286 stations with variable availability of observations were selected (min. area = 10 000 km<sup>2</sup>) \
The selected stations can be found stationLatLon.csv (merged daily and monthly).

## Python module
For fast installation / update of necessary modules it is recommended to use the mamba package manager.\
Current dependencies: numpy, pandas, alive_progress, netCDF4, xarray, multiprocessing.

The python module is used to extract raw data into homogeneous .csv files.
- Extraction of GRDC discharge, either daily or monthly (from .txt)
- Extraction of PCR-GLOBWB upstream averaged parameters (from data/allpoints_catchAttr.csv into stationLatLon.csv)
- Extraction of PCR-GLOBWB upstream averaged meteo input and state variables (from .netCDF). 

## R module
The R module follows the post-processing phases described in **manuscript**.
Dependencies can be installed using fun_0_install_dependencies.R.
These are loaded at the beginning of each script using fun_0_load_library.R. 

### 0_preprocess_grdc
0. Upscales daily discharge to monthly, merges daily and monthly if a station has both, keeps upscaled daily if available at a timestep.
1. Merges stations from stationLatLon_daily.csv and stationLatLon_monthly.csv into stationLatLon.csv
2. Calculates % missing data for the modelled years (here 1979-2019).

### 0_preprocess_predictors
0. Parameters: generates timeseries of static catchment attributes (.csv)
0. qMeteoStatevars: merges timeseries of meteo input and state variables (.csv)
1. Merge all predictors : merges Parameters and qMeteoStatevars (.csv)

### 1_correlation_analysis
bigTable : binds all stations predictor tables *allpredictors*

### 2_randomForest
0. Subsample -> Subsamples stationLatLon.csv to generate a training table that contains ~70% of all available timesteps. 
1. Tune -> Uses training table from 0 to tune Random Forest hyperparameters. 
2. Train / Testing -> Can be done per subsample (2,3) or in batch (4). Calculates variable importance and KGE (before and after post-processing).

### 3_visualization
Used to visualize all modelling phases:
- Map with percentage of missing data at GRDC stations. 
- Correlation plot to explore predictor selection. 
- Tuning Random Forest parameters. 
- Plot of variable importance with uncertainty averaged for all subsamples. 
- KGE: boxplots of each subsample and predictor configuration. 
- KGE: global maps (uncalibrated vs. post-processed). 
- Hydrographs: can be done for selected stations or in batch for all subsamples (only for allpredictors setup).
