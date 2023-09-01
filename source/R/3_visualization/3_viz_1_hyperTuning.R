####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

# cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")  #with grey
# cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") #with black

outputDir <- '../../../viz/'
dir.create(outputDir, showWarnings = F, recursive = T)

# # myPalette <- colorRampPalette((brewer.pal(9, "RdYlBu")))
# sc <- scale_color_manual(colours = myPalette(5), limits=c(1,5), 
#                            name='Subsample')
sc <- scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9", "#009E73", "#CC79A7"), 
                         name='Subsample: ')
setup <- c('allpredictors', 'qMeteoStatevars','meteoCatchAttr')

#### tuning mtry ####
mtryTuningList <- list()
mtryPlotList <- list()
for(i in 1:3){
  for(subsample in 1:5){
    
      tuning_dir <- paste0('../../../RF/1_tune/subsample_',subsample,'/')
      
      mtry_five <- read.csv(paste0(tuning_dir, 'hyper_grid_',setup[i],'_mtry.csv'))
      mtry_one <- read.csv(paste0(tuning_dir, 'hyper_grid_',setup[i],'_mtry_unit.csv'))
      
      mtry_tuning <- full_join(mtry_five, mtry_one) %>% arrange(.,mtry) %>% 
        mutate(.,subsample=factor(subsample))
      mtryTuningList[[subsample]] <- mtry_tuning
  }
      
    all_mtry_setup <- do.call(rbind, mtryTuningList)  
    mtryPlotData <- all_mtry_setup %>% pivot_longer(.,OOB_RMSE)
    
    if(i==1){    
      mtryPlot <- ggplot(mtryPlotData, aes(x=mtry,y=value, group=subsample, color=subsample))+
        geom_line(linewidth=0.5)+
        geom_point(aes(shape=subsample), size=1.5, alpha = 0.6, show.legend = F) +
        sc+
        ylim(0.00038, 0.00080)+
        ylab('OOB RMSE (m/d)\n')+
        labs(title=paste0(setup[i], '\n\n'))+
        # theme_minimal()+
        theme(plot.title = element_text(hjust = 0.5, size=20, face='bold'),
              axis.title = element_text(size=16),
              axis.text.y= element_text(size=12))
    }
    else{
      mtryPlot <- ggplot(mtryPlotData, aes(x=mtry,y=value, group=subsample, color=subsample))+
        geom_line(linewidth=0.5)+
        geom_point(aes(shape=subsample), size=1.5, alpha = 0.6, show.legend = F) +
        sc+
        ylim(0.00038, 0.00080)+
        labs(title=paste0(setup[i], '\n\n'))+
        # theme_minimal()+
        theme(plot.title = element_text(hjust = 0.5, size=20, face='bold'),
              axis.title = element_text(size=16),
              axis.title.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.text.y  = element_blank())
      
    }

    
    mtryPlotList[[i]] <- mtryPlot
}


#### tuning ntrees ####
ntreeTuningList <- list()
ntreePlotList <- list()
for(i in 1:3){
  for(subsample in 1:5){
    
      tuning_dir <- paste0('../../../RF/1_tune/subsample_',subsample,'/')
      
      ntree_tuning <- read.csv(paste0(tuning_dir, 'hyper_grid_',setup[i],'_ntrees.csv')) %>% 
        mutate(.,subsample=factor(subsample))
      
      ntreeTuningList[[subsample]] <- ntree_tuning
  }
  
    all_ntree_setup <- do.call(rbind, ntreeTuningList)
    ntreePlotData <- all_ntree_setup %>% pivot_longer(.,OOB_RMSE)
    
    if(i==1){    
      ntreePlot <- ggplot(ntreePlotData, aes(x=ntrees,y=value, group=subsample, color=subsample))+
        geom_line(size=0.5)+
        geom_point(aes(shape=subsample), size=1.5, alpha = 0.6, show.legend = F) +
        sc+
        ylim(0.00037, 0.00075)+
        ylab('OOB RMSE (m/d)\n')+
        xlab('ntrees\n')+
        labs(title='')+
        # theme_minimal()+
        theme(axis.title = element_text(size=16),
              axis.text.y= element_text(size=12))
    }
    else{
      ntreePlot <- ggplot(ntreePlotData, aes(x=ntrees,y=value, group=subsample, color=subsample))+
        geom_line(size=0.5)+
        geom_point(aes(shape=subsample), size=1.5, alpha = 0.6, show.legend = F) +
        sc+
        ylim(0.00037, 0.00075)+
        xlab('ntrees\n')+
        # theme_minimal()+
        theme(axis.title.x = element_text(size=16),
              axis.title.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.text.y  = element_blank())
    }
    
    ntreePlotList[[i]] <- ntreePlot
}


#patch it together
tuningPlot <- (mtryPlotList[[1]] + mtryPlotList[[2]] + mtryPlotList[[3]]) / 
  (ntreePlotList[[1]] + ntreePlotList[[2]] + ntreePlotList[[3]]) +
  plot_layout(guides = "collect") &
  guides(color = guide_legend(override.aes = list(linewidth = 2))) &
  theme(legend.position = 'bottom',
        legend.title = element_text(size=18),
        legend.text = element_text(size=18))
tuningPlot

ggsave(paste0(outputDir,'tuningPlot.png'), tuningPlot, height=8, width=10, units='in', dpi=600)