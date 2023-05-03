####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

subsample <- '5'

stationInfo <- read.csv(paste0('../../../RF/0_rf_input/subsample_',subsample, 
                               '/train_stations.csv')) %>% arrange(grdc_no)
train_table <- vroom(paste0('../../../RF/0_rf_input/subsample_',subsample, 
                               '/train_table_allpredictors.csv'), show_col_types = F)


for(i in 1:nrow(stationInfo)){
  
  station_no <- stationInfo$grdc_no[i]
  print(station_no)
  
  test_data <- read.csv(paste0('../../../data/predictors/pcr_allpredictors/pcr_allpredictors_',
                               station_no, '.csv')) %>% na.omit(.)
  
  stationInfo$train_contribution[i] <- nrow(test_data) / nrow(train_table)
  
}

stationInfo$train_contribution <- stationInfo$train_contribution*100
stationInfo <- select(stationInfo, grdc_no, wmo_reg, train_contribution)


for(i in 1:6){
  
  training_WMO_1 <- stationInfo[stationInfo[,'wmo_reg'] == i,] 
  summit <- sum(training_WMO_1$train_contribution)
  
  print(paste0('% of WMO_reg (', i, ') to training data is: ',summit))
  
  
}

#### descriptive statistics of stations ####
#stationInfo <- read.csv('../../../data/stationLatLon.csv')
#summary(stationInfo$area)
#summary(stationInfo$miss)
