#### processing ####
calculate_missing <- function(i){ 
  
  station_no <- stationInfo$grdc_no[i]
  print(station_no)
  
  grdc <- read.csv(paste0(grdcDir,'grdc_', station_no,'.csv'))
  
  # calculate missing percentage
  missing_perc <- round((sum(is.na(grdc$obs)) / nrow(grdc) * 100), 2)
  
  return(missing_perc)
}