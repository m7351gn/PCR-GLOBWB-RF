####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

#### create big table with all predictors to execute corranalysis ####
filePathPreds <- '../../../data/predictors/pcr_allpredictors/'
fileListPreds <- list.files(filePathPreds)
filenames <- paste0(filePathPreds, fileListPreds)

print('reading all tables...')
all_tables <- mclapply(filenames, vroom, show_col_types = F, mc.cores=8)
print('binding...')
bigTable <- do.call(rbind, all_tables)
bigTable <- na.omit(bigTable)

print('writing to disk...')
write.csv(bigTable, '../../../data/bigTable_allpredictors.csv' , row.names = F)