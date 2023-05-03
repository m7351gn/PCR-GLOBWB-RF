####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

#### set-up ####
stationInfo <- read.csv('../../../data/stationLatLon_catchAttr.csv')

outputDir <- '../../../data/predictors/pcr_parameters/'
dir.create(outputDir, showWarnings = FALSE, recursive = TRUE)
  
# datetime as pcr-globwb run
startDate <- '1979-01-01'
endDate <- '2019-12-31'
dates <- as.data.frame(seq(as.Date("1979-01-01"), as.Date("2019-12-31"), by="month"))
colnames(dates) <- 'datetime'

#### run ####
source('fun_0_preprocess_pcr_parameters.R')
mclapply(1:nrow(stationInfo), create_predictor_table, mc.cores=24)
