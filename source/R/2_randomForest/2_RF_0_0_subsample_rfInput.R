####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

stationInfo <- read.csv('../../../data/stationLatLon.csv')

subsample <- '5'
outputDir <- paste0('../../../RF/0_rf_input/subsample_',subsample,'/')
dir.create(outputDir, showWarnings = F, recursive = T)

#~ filePathPreds <- '../../../data/predictors/pcr_allpredictors/'
filePathPreds <- '../../../data/predictors/pcr_allpredictors/'
fileListPreds <- list.files(filePathPreds, pattern='.csv')
filenames <- paste0(filePathPreds, fileListPreds)

#---- subsample such that train_stations has between 2/3 and 70% of available data ----#
source('fun_2_0_subsample_train_test.R')
registerDoParallel(12)
print('sampling...')
repeat{
  
  ## subset train station, select and read file tables, collect, read nrow
  train_stations <- stationInfo[sample(nrow(stationInfo),1520),] #number of train stations depends on whole set dimension (~70%)
  train_table <- subsample_table(train_stations) %>% 
					mutate(datetime=as.Date(datetime))
  nrow_train <- nrow(train_table)
  
  print('finished: train dataset')
  
  ## same for test stations
  test_stations <- setdiff(stationInfo, train_stations)
  test_table <- subsample_table(test_stations)
  nrow_test <- nrow(test_table)
  
  print('finished: test dataset')
  
  ratio_subsamples <- nrow_train/(nrow_train+nrow_test)
  
  if(ratio_subsamples > 0.66 & ratio_subsamples < 0.7){
    print('subsample successful! writing...')
    break
        }
  else{
    print('subsample failed :/ train dataset too small/big... resampling...')
  }
}

# write tables: train_stations, test_stations, train_table
write.csv(train_stations, paste0(outputDir,'train_stations.csv'), row.names = F)
write.csv(test_stations, paste0(outputDir,'test_stations.csv'), row.names = F)
write.csv(train_table, paste0(outputDir,'train_table_allpredictors.csv'), row.names = F)
