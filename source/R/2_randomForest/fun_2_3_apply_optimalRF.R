# function to apply a trained RF to unseen data
# it writes complete tables for allpredictors and stores KGE for all setups

# key = qstatevars, allpredictors
apply_optimalRF <- function(i, key){
    
    station_no <- testStationInfo$grdc_no[i]
    print(station_no)
    
    test_data <- read.csv(paste0('../../../data/predictors/pcr_allpredictors/pcr_allpredictors_',
								 station_no, '.csv'))
                                
                                 
    rf.result <- test_data %>% 
      # predict discharge with trained RF
        mutate(pcr_corrected = predict(optimal_ranger, test_data) %>% predictions()) %>%
      # if pcr_corrected < 0 -> pcr_corrected=0
        mutate(pcr_corrected = replace(pcr_corrected, pcr_corrected<0,0)) %>%
      # calculate residuals
        mutate(res=obs-pcr) %>%
        mutate(res_corrected=obs-pcr_corrected) %>%
      # move new discharge variables before state variables
      relocate(pcr_corrected, .before=precipitation) %>%
      relocate(res, .before=precipitation) %>%
      relocate(res_corrected, .before=precipitation) %>%
      #keep only datetime, obs, pcr, pcr_corrected, res, res_corrected
        select(.,datetime:res_corrected)
    
    # save allpredictor tables to disk
    if(key=='allpredictors'){
        
        outputDirTables <- paste0(outputDirValidation, 'tables_',key, '/')
        dir.create(outputDirTables, showWarnings = F, recursive = T)
        write.csv(rf.result, paste0(outputDirTables, 'rf_result_',
                                    station_no, '.csv'), row.names = F)
                                    
                                }
    
    #calculate KGE uncalibrated and corrected
    rf.eval <- rf.result %>%
      summarise(grdc_no=station_no,
                KGE=KGE(sim = pcr, obs = obs,
                        s = c(1,1,1), na.rm = T, method = "2009"),
                KGE_corrected=KGE(sim = pcr_corrected, obs = obs,
                                  s = c(1,1,1), na.rm = T, method = "2009"),
              # KGE components (r,alpha,beta), uncalibrated and corrected pcrglob
                KGE_r=cor(obs,pcr,method='pearson',use='complete.obs'),
                KGE_r_corrected=cor(obs,pcr_corrected,method='pearson',use='complete.obs'),
                KGE_alpha=sd(pcr, na.rm=T)/sd(obs, na.rm=T),
                KGE_alpha_corrected=sd(pcr_corrected, na.rm=T)/sd(obs, na.rm=T),
                KGE_beta=mean(pcr, na.rm=T)/mean(obs, na.rm=T),
                KGE_beta_corrected=mean(pcr_corrected, na.rm=T)/mean(obs, na.rm=T),
              # other metrics
                NSE = NSE(sim = pcr, obs = obs, na.rm = T),
                NSE_corrected = NSE(sim = pcr_corrected, obs = obs, na.rm = T),
                RMSE=(((res)^2) %>% mean(na.rm=T) %>% sqrt),
                RMSE_corrected=(((res_corrected)^2) %>% mean(na.rm=T) %>% sqrt),
                MAE=res %>% abs %>% mean(na.rm=T),
                MAE_corrected=res_corrected %>% abs %>% mean(na.rm=T),
                nRMSE=(((res)^2) %>% mean(na.rm=T) %>% sqrt)/mean(obs),
                nRMSE_corrected=(((res_corrected)^2) %>% mean(na.rm=T) %>% sqrt)/mean(obs),
                nMAE=(res %>% abs %>% mean(na.rm=T))/mean(obs),
                nMAE_corrected=(res_corrected %>% abs %>% mean(na.rm=T))/mean(obs)
              )
    return(rf.eval)
}
