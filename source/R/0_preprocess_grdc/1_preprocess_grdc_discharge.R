####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

# set directories 
grdcDailyDir <- '../../../data/preprocess/grdc_discharge_daily/'
grdcMonthlyDir <- '../../../data/preprocess/grdc_discharge_monthly/'

outputDir <- '../../../data/preprocess/grdc_discharge/'
dir.create(outputDir, showWarnings = FALSE, recursive = TRUE)

stationInfo <- read.csv('../../../data/stationLatLon.csv')

# datetime as pcr-globwb run
startDate <- '1979-01-01'
endDateDaily <- '2019-12-31'
endDateMonthly <- '2019-12-01'
datesDaily <- as.data.frame(seq(as.Date("1979-01-01"), as.Date("2019-12-31"), by="days"))
datesMonthly <- as.data.frame(seq(as.Date("1979-01-01"), as.Date("2019-12-31"), by="months"))
colnames(datesDaily) <- 'datetime'
colnames(datesMonthly) <- 'datetime'

source('fun_1_preprocess_grdc.R')
lapply(1:nrow(stationInfo), reanalyse_grdc_discharge)
