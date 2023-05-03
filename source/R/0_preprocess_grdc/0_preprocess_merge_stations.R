####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

#### merge daily and monthly station list, so that if both daily and monthly exist they are mergeds
stations_daily <- read.csv('../../../data/stationLatLon_daily.csv')
stations_monthly <- read.csv('../../../data/stationLatLon_monthly.csv')

stations_dm <- merge(stations_daily, stations_monthly, 
                     by=intersect(names(stations_daily), names(stations_monthly)), 
                     all=TRUE)
write.csv(stations_dm,'../../../data/stationLatLon.csv', row.names=F)
