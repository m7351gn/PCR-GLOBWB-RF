####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

# set directories 
grdcDir <- '../../../data/preprocess/grdc_discharge/'
stationInfo <- read.csv('../../../data/stationLatLon.csv')

source('fun_1_calculate_missing.R')
missing_list <- lapply(1:nrow(stationInfo), calculate_missing)

missing_col <- do.call(rbind,missing_list) 
colnames(missing_col) <- 'miss'
summary(missing_col)

stationInfo <- cbind(stationInfo,missing_col) 

write.csv(stationInfo, '../../../data/stationLatLon.csv', row.names=F)


