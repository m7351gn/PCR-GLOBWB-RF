# cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")  #with grey
# cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") #with black

####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####
library('ggh4x')

outputDir <- '../../../viz/'
dir.create(outputDir, showWarnings = F, recursive = T)

setup <- c('allpredictors','qMeteoStatevars','meteoCatchAttr')
#### data preparation ####
subsample_KGE_list <- list ()
for(subsample in 1:5){
  
  rf.eval.uncalibrated <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                          '/KGE_allpredictors.csv')) %>%
    select(.,grdc_no, KGE, KGE_r, KGE_alpha, KGE_beta) %>%
    mutate(.,setup=factor('uncalibrated')) %>%
    mutate(.,subsample=factor(subsample))
  
  #read meteocatchattr
  rf.eval.meteoCatchAttr <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                            '/KGE_meteoCatchAttr.csv')) %>% 
    select(.,grdc_no, KGE_corrected, KGE_r_corrected, KGE_alpha_corrected, KGE_beta_corrected) %>% 
    rename(., KGE=KGE_corrected, KGE_r=KGE_r_corrected, KGE_alpha=KGE_alpha_corrected, KGE_beta=KGE_beta_corrected) %>% 
    mutate(.,setup=factor(setup[3])) %>% 
    mutate(.,subsample=factor(subsample)) 
  
  #read qmeteostatevars
  rf.eval.qMeteoStatevars <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                             '/KGE_qMeteoStatevars.csv')) %>% 
    select(.,grdc_no, KGE_corrected, KGE_r_corrected, KGE_alpha_corrected, KGE_beta_corrected) %>% 
    rename(., KGE=KGE_corrected, KGE_r=KGE_r_corrected, KGE_alpha=KGE_alpha_corrected, KGE_beta=KGE_beta_corrected) %>% 
    mutate(.,setup=factor(setup[2])) %>% 
    mutate(.,subsample=factor(subsample))
  
  #read allpredictors
  rf.eval.allpredictors <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                           '/KGE_allpredictors.csv')) %>% 
    select(.,grdc_no, KGE_corrected, KGE_r_corrected, KGE_alpha_corrected, KGE_beta_corrected) %>% 
    rename(., KGE=KGE_corrected, KGE_r=KGE_r_corrected, KGE_alpha=KGE_alpha_corrected, KGE_beta=KGE_beta_corrected) %>% 
    mutate(.,setup=factor(setup[1])) %>% 
    mutate(.,subsample=factor(subsample)) 
  
  #put together in one list
  subsample_KGE <- rbind(rf.eval.uncalibrated, rf.eval.allpredictors, rf.eval.qMeteoStatevars, rf.eval.meteoCatchAttr)
  
  subsample_KGE_list[[subsample]] <- subsample_KGE
  
}

allData <- do.call(rbind, subsample_KGE_list)
allDataCum <- allData %>% mutate(subsample='Cumulative')
allData <- rbind(allData,allDataCum)

plotData <- allData %>% pivot_longer(KGE:KGE_beta, names_to = "KGE_component", 
                                     values_to = "value") %>% 
  mutate(setup = factor(setup, levels=c('uncalibrated', 'qMeteoStatevars','meteoCatchAttr','allpredictors'))) %>%
  mutate(KGE_component = fct_relevel(KGE_component, 'KGE','KGE_r','KGE_alpha','KGE_beta'))


#### plot boxplots ####
KGE_boxplot <- ggplot(plotData , mapping = aes(setup, value, fill=setup))+
  geom_boxplot(outlier.shape = NA) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  facet_grid(vars(KGE_component), vars(subsample), scales='free_y', switch='y')+
  labs(title = "Subsample\n")+
  scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9", "#009E73"))+
  theme(plot.title = element_text(hjust=0.5, size=16),
        axis.title=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y= element_text(size=12),
        legend.position = 'bottom',
        legend.title=element_blank(),
        legend.key.size = unit(1, 'cm'),
        legend.text = element_text(size=14),
        strip.text = element_text(size=12))+
  facetted_pos_scales(y = list(
    KGE_component == "KGE" ~ scale_y_continuous(position='right', limits = c(-4, 1)),
    KGE_component == "KGE_r" ~ scale_y_continuous(position='right', limits = c(0, 1)),
    KGE_component == "KGE_alpha" ~ scale_y_continuous(position='right', limits = c(-0.5,5)),
    KGE_component == "KGE_beta" ~ scale_y_continuous(position='right', limits = c(-0.5,5.5))))
KGE_boxplot

ggsave(paste0(outputDir,'KGE_boxplots.png'), KGE_boxplot, height=10, width=10, units='in', dpi=600)



#### some stats (paper section 3.3.) ####
uncalibratedCum <- allDataCum %>% filter(setup=='uncalibrated')
qmeteostateCum <- allDataCum %>% filter(setup=='qMeteoStatevars')
meteocatchCum <- allDataCum %>% filter(setup=='meteoCatchAttr')
allpredictorsCum <- allDataCum %>% filter(setup=='allpredictors')

summary(uncalibratedCum$KGE)
summary(qmeteostateCum$KGE)
summary(meteocatchCum$KGE)
summary(allpredictorsCum$KGE)

summary(uncalibratedCum$KGE_r)
summary(qmeteostateCum$KGE_r)
summary(meteocatchCum$KGE_r)
summary(allpredictorsCum$KGE_r)

summary(uncalibratedCum$KGE_alpha)
summary(qmeteostateCum$KGE_alpha)
summary(meteocatchCum$KGE_alpha)
summary(allpredictorsCum$KGE_alpha)

summary(uncalibratedCum$KGE_beta)
summary(qmeteostateCum$KGE_beta)
summary(meteocatchCum$KGE_beta)
summary(allpredictorsCum$KGE_beta)
