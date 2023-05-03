create_predictor_table <- function(i){
  
  station_no <- stationInfo$grdc_no[i]
  print(station_no)
  ## do stuff: select columns of pcr parameters from stationLatLon_catchAttr.csv
  catchAttributes <- stationInfo[i,] %>% select(.,airEntry1:tanSlope)
  
  # create table with static predictors (expand line to table using dates vector)
  catchAttr_ts <- merge(dates,catchAttributes)
  
  write.csv(catchAttr_ts, paste0(outputDir,'pcr_parameters_',
                               station_no, '.csv'), row.names = F)
  
  
}
