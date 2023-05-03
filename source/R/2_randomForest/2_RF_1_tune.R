####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####
source('fun_2_1_hyperTuning.R')

#--------------RF---------------
#-----------1. Tune parameter---------------#
num.threads <- 48 
min.node.size = 5
tuned_mtry <- read.csv('../../../RF/2_train/tuned_mtry.csv', header=T) %>% 
    select(., -setup)

for(subsample in 1:5){
    
    print(paste0('subsample: ', subsample))
    #select subsample predictors
    train_data <- vroom(paste0('../../../RF/0_rf_input/', 'subsample_',subsample,
				'/train_table_allpredictors.csv'), show_col_type=F)

    outputDir <- paste0('../../../RF/1_tune/subsample_',subsample,'/')
    dir.create(outputDir, showWarnings = F, recursive = T)
    
#~     print(tuned_mtry[,subsample])
    #tuning
    #### all predictors ####
    print('tuning: allpredictors')

    rf_input <- train_data %>% select(., -datetime)
    
    mtry <- tuned_mtry[1,subsample]
    
    hyper_grid <- expand.grid(
      ntrees = c(10,50,100,150,200,300,500,700,900,1100,1300,1500),
#~       ntrees = 200, #only use 200 trees for rapid tuning
#~       mtry = seq(11,21, by=1)
      mtry = mtry
    )

    hyper_trains <- lapply(1:nrow(hyper_grid), hyper_tuning)

    for(i in 1:nrow(hyper_grid)){
      hyper_grid$ntrees[i]   <- hyper_trains[[i]]$num.trees
      hyper_grid$mtry[i]     <- hyper_trains[[i]]$mtry
      hyper_grid$OOB_RMSE[i] <- sqrt(hyper_trains[[i]]$prediction.error)
    }
      
    print(paste0('output csv file: ', outputDir, 'hyper_grid_allpredictors_ntrees.csv'))
    write.csv(hyper_grid, paste0(outputDir, 'hyper_grid_allpredictors_ntrees.csv'), row.names = F)


    #### qmeteostatevars ####
    print('tuning: qMeteoStatevars')
    

    rf_input <- train_data %>% select(., -datetime) %>% 
      select(.,obs:nonIrrWaterConsumption)
      
    mtry <- tuned_mtry[2,subsample]
    
    hyper_grid <- expand.grid(
      ntrees = c(10,50,100,150,200,300,500,700,900,1100,1300,1500),
#~       ntrees = 200, #only use 200 trees for rapid tuning
#~       mtry = seq(16,25, by=1)
      mtry = mtry
    )

    hyper_trains <- lapply(1:nrow(hyper_grid), hyper_tuning)

    for(i in 1:nrow(hyper_grid)){
      hyper_grid$ntrees[i]   <- hyper_trains[[i]]$num.trees
      hyper_grid$mtry[i]     <- hyper_trains[[i]]$mtry
      hyper_grid$OOB_RMSE[i] <- sqrt(hyper_trains[[i]]$prediction.error)
    }
      
    print(paste0('output csv file: ', outputDir, 'hyper_grid_qMeteoStatevars_ntrees.csv'))
    write.csv(hyper_grid, paste0(outputDir, 'hyper_grid_qMeteoStatevars_ntrees.csv'), row.names = F)
      
      
    #### meteo, catchattr ####
    print('tuning: meteoCatchAttr')
    rf_input <- train_data %>% select(., -datetime) %>% 
      select(obs, precipitation:referencePotET, airEntry1:tanSlope)

    mtry <- tuned_mtry[3,subsample]
    
    hyper_grid <- expand.grid(
      ntrees = c(10,50,100,150,200,300,500,700,900,1100,1300,1500),
#~       ntrees = 200, #only use 200 trees for rapid tuning
#~       mtry = seq(16,26,by=1)
      mtry = mtry
    )

    hyper_trains <- lapply(1:nrow(hyper_grid), hyper_tuning)

    for(i in 1:nrow(hyper_grid)){
      hyper_grid$ntrees[i]   <- hyper_trains[[i]]$num.trees
      hyper_grid$mtry[i]     <- hyper_trains[[i]]$mtry
      hyper_grid$OOB_RMSE[i] <- sqrt(hyper_trains[[i]]$prediction.error)
    }
      
    print(paste0('output csv file: ', outputDir, 'hyper_grid_meteoCatchAttr_ntrees.csv'))
    write.csv(hyper_grid, paste0(outputDir, 'hyper_grid_meteoCatchAttr_ntrees.csv'), row.names = F)

}
