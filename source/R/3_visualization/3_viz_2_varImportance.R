####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

outputDir <- '../../../viz/'
dir.create(outputDir, showWarnings = F, recursive = T)

sc <- scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9", "#009E73", "#CC79A7"), 
                         name='Subsample: ')
setup <- c('allpredictors', 'qMeteoStatevars','meteoCatchAttr')

remove <- c('datetime', 'obs')
predNames <- read.csv('../../../data/predictors/pcr_allpredictors/pcr_allpredictors_1104150.csv') %>% 
  names(.) %>% setdiff(.,remove) 
predNames[1] <- 'pcrFlowDepth'

timePred_names <- predNames[1:25]
staticPred_names <- predNames[26:54]


#### 5 subsamples variable importance ####
viList <- list()
viPlotList <- list()

for(i in 1:3){
  
  for(subsample in 1:5){
    
    trainDir <- paste0('../../../RF/2_train/subsample_',subsample,'/')
    
    if(subsample==1){
      viList[[subsample]] <- read.csv(paste0(trainDir, 'varImportance_',setup[i],'.csv')) %>% 
        rename(importance_1=importance)
    # } else if(subsample==5){
    #   viList[[subsample]] <- read.csv(paste0(trainDir, 'varImportance_',setup[i],'.csv')) %>%
    #     select(., importance) %>% rename(importance_5=importance)
    } else{
      viList[[subsample]] <- read.csv(paste0(trainDir, 'varImportance_',setup[i],'.csv')) %>%
        select(., importance) %>%  rename(!!paste0('importance_',subsample) := importance)
    }
  }
  
  
  viSetup <- as.data.frame(do.call(cbind, viList))
  # calculate avg and standard deviation of variable importances
  for(j in 1:nrow(viSetup)){
    viSetup$importance_avg[j] <- sum(viSetup[j,2:6])/5
    viSetup$importance_sd[j] <- sd(viSetup[j,2:6])
  }
  
  #rename pcr to pcrFlowDepth
  if(i==1 | i==2){
    viSetup[1,1]='pcrFlowDepth'
  }
  
  #gather
  plotData <- viSetup %>% top_n(20, importance_avg) %>% 
    select(-(importance_1:importance_5)) %>% 
    arrange(., desc(importance_avg)) %>%
    gather('key','value', importance_avg) 
  
  # add predictor type (static or time-variant) to color plot text
  for(j in 1:nrow(plotData)){
    plotData$predictorType[j] <- case_when((plotData$names[j] %in% timePred_names)~'pred_time',
                                          (plotData$names[j] %in% staticPred_names)~'pred_static')
  }
  
  labColor <- rev(ifelse(plotData$predictorType == 'pred_time', "red", "blue"))
  
  
  #plot 
  if(i==3){
    
    viPlot <- ggplot(plotData) +
      geom_col(aes(reorder(names, c(value[key=='importance_avg'])), sqrt(value)),
               position = 'dodge', fill='khaki') +
      geom_errorbar(aes(reorder(names, c(value[key=='importance_avg'])),
                        ymin=sqrt(value)-sqrt(importance_sd), ymax=sqrt(value)+sqrt(importance_sd), 
                        width=0.8, size=0.1, colour="orange"), show.legend = F) +
      # geom_col(aes(reorder(names, c(value[key=='importance_avg'])), value),
      #          position = 'dodge', fill='khaki') +
      # geom_errorbar(aes(reorder(names, c(value[key=='importance_avg'])), 
      #                   ymin=value-importance_sd, ymax=value+importance_sd, width=0.4, 
      #                   colour="orange", alpha=0.9, size=1.3), show.legend = F) +
      ylim(0,0.65)+
      coord_flip() +
      theme_light()+
      labs(x=NULL, y='\nsqrt(DecNodeImpurity)', 
           title=paste0('\n', setup[i],'\n'))+     #mean decrease in node impurity (sd)
      theme(
        axis.text.y = element_text(size = 35, color=labColor),
        axis.text.x = element_text(size = 33),
        title = element_text(size = 40))
  }
  else{
    
    viPlot <- ggplot(plotData) +
      geom_col(aes(reorder(names, c(value[key=='importance_avg'])), sqrt(value)),
               position = 'dodge', fill='khaki') +
      geom_errorbar(aes(reorder(names, c(value[key=='importance_avg'])),
                        ymin=sqrt(value)-sqrt(importance_sd), ymax=sqrt(value)+sqrt(importance_sd), 
                        width=0.8, size=0.1, colour="orange"), show.legend = F) +
      # geom_col(aes(reorder(names, c(value[key=='importance_avg'])), value),
      #          position = 'dodge', fill='khaki') +
      # geom_errorbar(aes(reorder(names, c(value[key=='importance_avg'])), 
      #                   ymin=value-importance_sd, ymax=value+importance_sd, width=0.4, 
      #                   colour="orange", alpha=0.9, size=1.3), show.legend = F) +
      ylim(0,0.65)+
      coord_flip() +
      theme_light()+
      labs(x=NULL, y=NULL, 
           title=paste0('\n', setup[i],'\n'))+  
      theme(
        axis.text.y = element_text(size = 35, color=labColor),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        # strip.text.x = element_text(size = 15, color = 'black'),
        # strip.background = element_rect(colour = "transparent", fill = "white"),
        # strip.text.y = element_text(size = 15, color = 'black'),
        title = element_text(size = 40))
  
  }
  
    viPlotList[[i]] <- viPlot
}

trainingPlot <- viPlotList[[1]] / viPlotList[[2]] / viPlotList[[3]]  
trainingPlotSize <- trainingPlot #+ plot_layout(heights=c(5,3,3))
trainingPlotSize

ggsave(paste0(outputDir, 'varImportance.png'), trainingPlotSize, height=35, width=25, units='in', dpi=600)

