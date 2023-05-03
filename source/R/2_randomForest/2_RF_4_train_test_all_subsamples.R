####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####
source('fun_2_2_trainRF.R')
source('fun_2_3_apply_optimalRF.R')

#-------train RF with tuned parameters on 70% of available observations----------
num.threads <- 48
num.cores <- 48
trees <- 500
min.node.size = 5
tuned_mtry <- read.csv('../../../RF/2_train/tuned_mtry.csv', header=T) %>% 
    select(., -setup)

for(subsample in 1:5){
    
    print(paste0('subsample: ', subsample))
    #select subsample predictors
    train_data <- vroom(paste0('../../../RF/0_rf_input/', 'subsample_',subsample,
				'/train_table_allpredictors.csv'), show_col_type=F)
    testStationInfo <- read.csv(paste0('../../../RF/0_rf_input/subsample_',subsample,'/test_stations.csv'))

    outputDir <- paste0('../../../RF/2_train/subsample_',subsample,'/')
    dir.create(outputDir, showWarnings = F, recursive = T)
    outputDirValidation <- paste0('../../../RF/3_validate/subsample_',subsample,'/')
    dir.create(outputDirValidation, showWarnings = F, recursive = T)


    #### all predictors ####
    #train
    print('training: allpredictors...')
    rf_input <- train_data %>% select(., -datetime) #here select the wished predictors
    mtry <- tuned_mtry[1,subsample]
    optimal_ranger <- trainRF(input_table=rf_input, num.trees=trees, mtry=mtry)

    #save trained model and variable importance rank
    print('saving...')
    #~ saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_allpredictors.rds'))                    
    vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
      mutate(importance=optimal_ranger$variable.importance)                     
    write.csv(vi_df, paste0(outputDir,'varImportance_allpredictors.csv'), row.names=F)

    #run validation script
    key='allpredictors'
    print(paste0(key,' : calculation initiated...'))
    KGE_list <- mclapply(1:nrow(testStationInfo), key=key, apply_optimalRF, mc.cores=num.cores)
    rf.eval <- do.call(rbind,KGE_list)
    write.csv(rf.eval, paste0(outputDirValidation, 'KGE_' , key, '.csv'), row.names = F)
    print('allpredictors: finished validation...')


    #### only q, meteo and statevars as predictors ####
    #train
    print('training: qMeteoStatevars')              
    rf_input <- train_data %>% select(., -datetime) %>% 
      select(.,obs:nonIrrWaterConsumption) #here select the wished predictors
    mtry <- tuned_mtry[2,subsample]
    optimal_ranger <- trainRF(input_table=rf_input, num.trees=trees, mtry=mtry)

    #save trained model and variable importance rank
    print('saving...')
    #~ saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_qMeteoStatevars.rds')) 
    vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
      mutate(importance=optimal_ranger$variable.importance)
    write.csv(vi_df, paste0(outputDir,'varImportance_qMeteoStatevars.csv'), row.names=F)

    #run validation script
    key='qMeteoStatevars'
    print(paste0(key,' : calculation initiated...'))
    KGE_list <- mclapply(1:nrow(testStationInfo), key=key, apply_optimalRF, mc.cores=num.cores)
    rf.eval <- do.call(rbind,KGE_list)
    write.csv(rf.eval, paste0(outputDirValidation, 'KGE_' , key, '.csv'), row.names = F)
    print('qMeteoStatevars: finished validation...')


    #### meteo, catchment attributes ####
    #train
    print('training: meteoCatchAttr...')
    rf_input <- train_data %>% select(., -datetime) %>% 
      select(obs, precipitation:referencePotET, airEntry1:tanSlope) #here select the wished predictors
    mtry <- tuned_mtry[3,subsample]
    optimal_ranger <- trainRF(input_table=rf_input, num.trees=trees, mtry=mtry)
    #save trained model and variable importance rank
    print('saving...')
    #~ saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_meteoCatchAttr.rds'))                    
    vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
      mutate(importance=optimal_ranger$variable.importance)                     
    write.csv(vi_df, paste0(outputDir,'varImportance_meteoCatchAttr.csv'), row.names=F)

    #run validation script
    key='meteoCatchAttr'
    print(paste0(key,' : calculation initiated...'))
    KGE_list <- mclapply(1:nrow(testStationInfo), key=key, apply_optimalRF, mc.cores=num.cores)
    rf.eval <- do.call(rbind,KGE_list)
    write.csv(rf.eval, paste0(outputDirValidation, 'KGE_' , key, '.csv'), row.names = F)
    print('meteoCatchAttr: finished validation...')
    
}
