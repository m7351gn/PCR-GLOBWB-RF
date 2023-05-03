####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

stationInfo <- read.csv('../../../data/stationLatLon.csv')

filePathCatchAttr <- paste0('../../../data/predictors/pcr_parameters/')
filePathStatevars <- paste0('../../../data/predictors/pcr_qMeteoStatevars/')

outputDir <- '../../../data/predictors/pcr_allpredictors/'
dir.create(outputDir, showWarnings = FALSE, recursive = TRUE)

### function to merge tables of time-variant and statics predictors
merge_predictors <- function(i){
  
  station_no <- stationInfo$grdc_no[i]
  print(station_no)
	
  CatchAttrTable <- read.csv(paste0(filePathCatchAttr , 'pcr_parameters_',station_no,'.csv'))
  statevarsTable <- read.csv(paste0(filePathStatevars , 'pcr_qMeteoStatevars_',station_no,'.csv'))
  allPredictors <- inner_join(statevarsTable, CatchAttrTable, by='datetime') %>% 
    mutate(datetime=as.Date(datetime))
  write.csv(allPredictors, paste0(outputDir, 'pcr_allpredictors_',station_no,'.csv'), row.names=FALSE)
  
}

mclapply(1:nrow(stationInfo), merge_predictors, mc.cores=24)
