# function that tunes rf hyperparameters )ntree, mtry)
# based on a series of combination given in hyper_grid

hyper_tuning <- function(i){
  
  print(paste0(i,'/',nrow(hyper_grid)))
  
  model <- ranger(
    formula = obs~.,
    data = rf_input,
    num.trees = hyper_grid$ntrees[i],
    mtry = hyper_grid$mtry[i],
    min.node.size   = min.node.size,
    seed = 123,
    num.threads=num.threads
  )
}
