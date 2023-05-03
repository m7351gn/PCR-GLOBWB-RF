#### training function ####

trainRF <- function(input_table, num.trees, mtry){
	
  ranger(
	  formula         = obs ~ ., 
	  data            = input_table,  # pay attention here to only use actual predictors, excluding datetime, obs, pcr
	  num.trees       = num.trees, #manually choose parsimonious amount of trees
	  mtry            = mtry, #manually choose the proper mtry, 15 or 20 
	  min.node.size   = min.node.size,
	  seed = 123,
	  importance = 'impurity', # 'permutation'
	  num.threads=num.threads
  
 )
}
