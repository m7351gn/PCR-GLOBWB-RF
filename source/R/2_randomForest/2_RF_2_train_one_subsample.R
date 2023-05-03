####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####
source('fun_2_2_trainRF.R')

subsample <- '1'

train_data <- vroom(paste0('../../../RF/0_rf_input/subsample_',subsample,
				'/train_table_allpredictors.csv'), show_col_type=F)
                
testStationInfo <- read.csv(paste0('../../../RF/0_rf_input/subsample_',subsample,'/test_stations.csv'))

outputDir <- paste0('../../../RF/2_train/subsample_',subsample,'/')
dir.create(outputDir, showWarnings = F, recursive = T)
num.threads <- 24
min.node.size <- 5

#-------train RF with tuned parameters on 70% of available observations----------
#~ #### only q and statevars as predictors
#~ print('training: qstatevars')
#~ train_data <- vroom(paste0('../../../RF/rf_input/train_table_qstatevars.csv'),
#~                      show_col_types = F)                     
#~ rf_input <- train_data %>% select(., -datetime)
#~ # training (choose hyperparameters)
#~ optimal_ranger <- trainRF(rf_input, 900, 15)
#~ # save trained model to disk
#~ print('saving...')
#~ saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_qstatevars.rds')) 
#~ #variable importance
#~ vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
#~   mutate(importance=optimal_ranger$variable.importance)
#~ write.csv(vi_df, paste0(outputDir,'varImportance_qstatevars.csv'), row.names=F)


#### all predictors
print('training: all predictors...')
#~ train_data <- vroom(paste0('../../../RF/rf_input/train_table_allpredictors.csv'),
#~                      show_col_types = F)
rf_input <- train_data %>% select(., -datetime)
optimal_ranger <- trainRF(rf_input, 500, 26)

print('saving...')
saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_allpredictors.rds'))                    
vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
  mutate(importance=optimal_ranger$variable.importance)                     
write.csv(vi_df, paste0(outputDir,'varImportance_allpredictors.csv'), row.names=F)


#~ #### meteo, catchment attributes
#~ print('training: meteo, catchAttr...')
#~ train_data <- vroom(paste0('../../../RF/rf_input/train_table_allpredictors.csv'),
#~                     show_col_types = F)
#~ rf_input <- train_data %>% select(., -datetime) %>%  
#~   select(obs, precipitation:referencePotET, area_pcr:aridityIdx)
#~ optimal_ranger <- trainRF(rf_input, 900, 20)

#~ print('saving...')
#~ saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_meteoCatchAttr.rds'))                    
#~ vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
#~   mutate(importance=optimal_ranger$variable.importance)                     
#~ write.csv(vi_df, paste0(outputDir,'varImportance_meteoCatchAttr.csv'), row.names=F)

