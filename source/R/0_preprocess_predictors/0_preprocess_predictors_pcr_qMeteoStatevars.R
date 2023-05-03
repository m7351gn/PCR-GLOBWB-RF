####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

stationInfo <- read.csv('../../../data/stationLatLon.csv')

#grdc stations full time series
filePathGrdc <- paste0('../../../data/preprocess/grdc_discharge/')
#pcr-globwb time series 1979-2019
filePathDischarge <- paste0('../../../data/preprocess/pcr_discharge/')
filePathStatevars <- paste0('../../../data/preprocess/pcr_statevars/')

outputDir <- '../../../data/predictors/pcr_qMeteoStatevars/'
dir.create(outputDir, showWarnings = FALSE, recursive = TRUE)

# datetime as pcr-globwb run
startDate <- '1979-01-01'
endDate <- '2019-12-31'
dates <- seq(as.Date("1979-01-01"), as.Date("2019-12-31"), by="month")

source('fun_0_preprocess_pcr_qMeteoStatevars.R')
mclapply(1:nrow(stationInfo), create_predictor_table, mc.cores=48)