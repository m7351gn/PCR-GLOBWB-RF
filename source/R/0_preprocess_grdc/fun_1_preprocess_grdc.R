#### processing ####
# 1.read daily (if exists) grdc timeseries 
# 2.extend time series 1979-2019, adding NAs where grdc is missing (all=T)
# 3.cut time series at 1979-2019
# 4.upscale daily to monthly (mean)

reanalyse_grdc_discharge <- function(i){ 
  
  station_no <- stationInfo$grdc_no[i]
  print(station_no)
  
  if(file.exists(paste0(grdcDailyDir, 'grdc_daily_',station_no,'.csv'))){
    obsDaily <- vroom(paste0(grdcDailyDir, 'grdc_daily_',station_no,'.csv'), show_col_types=FALSE) %>%
      mutate(datetime=as.Date(datetime)) 
    obsDailyExt <- merge(datesDaily,obsDaily, all=T)
    obsDailyNew <- obsDailyExt[which(obsDailyExt$datetime==startDate):which(obsDailyExt$datetime==endDateDaily),] %>% 
      mutate(datetime=as.Date(datetime)) %>% replace_with_na(replace = list(obs = -999))
    
    obsDaily2Monthly <- obsDailyNew %>% mutate(datetime = floor_date(obsDailyNew$datetime, 'month')) %>% 
      group_by(datetime) %>% 
      summarise(obs=mean(obs))
    row.names(obsDaily2Monthly) <- NULL
  }
  
  #same for monthly (except upscaling)
  if(file.exists(paste0(grdcMonthlyDir, 'grdc_monthly_',station_no,'.csv'))){
    obsMonthly <- vroom(paste0(grdcMonthlyDir, 'grdc_monthly_',station_no, '.csv'), show_col_types=FALSE) %>%
      mutate(datetime=as.Date(datetime)) %>%
      replace_with_na(.,replace = list(obs = -999)) %>%
      replace_with_na(.,replace = list(calculated = -999))
      obsMonthlyExt <- merge(datesMonthly,obsMonthly, all=T)
    
    obsMonthlyNew <- obsMonthlyExt[which(obsMonthlyExt$datetime==startDate):which(obsMonthlyExt$datetime==endDateMonthly),] %>% 
      mutate(datetime=as.Date(datetime))
    row.names(obsMonthlyNew) <- NULL
  }
  
  #### assign new monthly observations #### 
  
  # if only daily exists
  if( file.exists(paste0(grdcDailyDir, 'grdc_daily_',station_no,'.csv')) && 
      !file.exists(paste0(grdcMonthlyDir, 'grdc_monthly_',station_no,'.csv'))){
    
    obsReanalysis <- obsDaily2Monthly
    
  } else if (!file.exists(paste0(grdcDailyDir, 'grdc_daily_',station_no,'.csv')) && 
             file.exists(paste0(grdcMonthlyDir, 'grdc_monthly_',station_no,'.csv'))){
    # if only monthly exists
    
    obsReanalysis <- obsMonthlyNew %>% select(.,c('datetime','obs'))
    
  } else if ( file.exists(paste0(grdcDailyDir, 'grdc_daily_',station_no,'.csv')) && 
              file.exists(paste0(grdcMonthlyDir, 'grdc_monthly_',station_no,'.csv'))){
    # if both exists
    
    obsReanalysis <- obsMonthlyNew #%>% mutate(., obs[which(!is.na(calculated))])
    idx <- which(!is.na(obsReanalysis$calculated)) # index of daily upscale not na
    obsReanalysis$obs[idx] <- obsReanalysis$calculated[idx] #assign daily upscaled when exists
    obsReanalysis <- obsReanalysis %>% select(.,c('datetime','obs'))
  }
  
  # write to disk
  write.csv(obsReanalysis, paste0(outputDir,'grdc_',station_no,'.csv'), row.names=F)
}