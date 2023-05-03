#function that reads subsample station q_discharge files and collects them in table
subsample_table <- function(subdataset){
  
  pat <- paste(subdataset$grdc_no, collapse = '|')
  sub_filenames <- filenames[grep(pat, filenames)]
  
  sub_datas  <- foreach(i=1:length(sub_filenames)) %dopar% 
    vroom(sub_filenames[i], show_col_type=F)
  
  sub_table <- do.call(rbind, sub_datas) %>% na.omit(.)
  
  return(sub_table)
}

