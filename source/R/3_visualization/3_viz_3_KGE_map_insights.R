# cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")  #with grey
# cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") #with black

####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####
library('ggh4x')

#script that plots map of KGE for uncalibrated and allpredictors, averaged over
#5 test subsamples and insights on which stations have high/low KGE

outputDir <- '../../../viz/'
dir.create(outputDir, showWarnings = F, recursive = T)

stationInfoMissing <- read.csv('../../../data/stationLatLon.csv') %>% 
  select(grdc_no, miss)
stationInfo <- read.csv('../../../data/stationLatLon_catchAttr.csv') %>% 
  select(grdc_no, lon, lat, area, aridityIdx) %>% inner_join(., stationInfoMissing)

#### data preparation ####
#change benchmark from uncalibrated to meteoCatchAttr
subsample_KGE_list <- list ()
for(subsample in 1:5){
  
  # rf.eval.uncalibrated <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
  #                                         '/KGE_allpredictors.csv')) %>%
  #   select(.,grdc_no, KGE) %>%
  #   mutate(.,setup=factor('uncalibrated')) %>% 
  #   mutate(.,subsample=factor(subsample)) 
  
  rf.eval.meteoCatchAttr <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                          '/KGE_meteoCatchAttr.csv')) %>%
    select(.,grdc_no, KGE) %>%
    mutate(.,setup=factor('meteoCatchAttr')) %>% 
    mutate(.,subsample=factor(subsample)) 
  
  #read allpredictors
  rf.eval.allpredictors <- read.csv(paste0('../../../RF/3_validate/subsample_', subsample,
                                           '/KGE_allpredictors.csv')) %>% 
    select(.,grdc_no, KGE_corrected) %>% 
    rename(., KGE=KGE_corrected) %>% 
    mutate(.,setup=factor('allpredictors'))  %>% 
    mutate(.,subsample=factor(subsample)) 
  
  #put together in one list
  subsample_KGE <- rbind(rf.eval.meteoCatchAttr, rf.eval.allpredictors)
  
  subsample_KGE_list[[subsample]] <- subsample_KGE
  
}

plotData <- do.call(rbind, subsample_KGE_list)

# plotData_uncalibrated <- plotData %>% filter(.,setup=='uncalibrated') %>% 
#   group_by(grdc_no) %>% 
#   summarise(mean_test_KGE_uncalibrated = mean(KGE)) %>% na.omit(.) %>% 
#   inner_join(., stationInfo) %>%
#   mutate(.,setup=factor('uncalibrated'))

plotData_meteoCatchAttr <- plotData %>% filter(.,setup=='meteoCatchAttr') %>% 
  group_by(grdc_no) %>% 
  summarise(mean_test_KGE_meteoCatchAttr = mean(KGE)) %>% na.omit(.) %>% 
  inner_join(., stationInfo) %>%
  mutate(.,setup=factor('meteoCatchAttr'))

plotData_allpredictors <- plotData %>% filter(.,setup=='allpredictors') %>% 
  group_by(grdc_no) %>% 
  summarise(mean_test_KGE_allpredictors = mean(KGE)) %>% na.omit(.) %>% 
  inner_join(., stationInfo) %>%
  mutate(.,setup=factor('allpredictors'))


#### plot KGE map uncalibrated, allpredictors ####
wg <- map_data("world")

#-----------KGE--------------#
#set KGE intervals 
breaks=c(-Inf, -0.41, 0, 0.2, 0.4, 0.6, 0.8, 0.9, 1)
labels=c('KGE < -0.41','-0.41 < KGE < 0', '0 < KGE < 0.2','0.2 < KGE < 0.4',
         '0.4 < KGE < 0.6','0.6 < KGE < 0.8','0.8 < KGE < 0.9','0.9 < KGE < 1')

# KGE_map_uncalibrated <- ggplot() +
#   geom_map(
#     data = wg, map = wg,
#     aes(long, lat, map_id = region),
#     color = "white", fill= "grey"
#   ) +
#   theme_map()+
#   xlim(-180,180)+
#   ylim(-55,75)+
#   geom_point(plotData_uncalibrated, mapping = aes(x = lon, y = lat,
#                                       fill=cut(mean_test_KGE_uncalibrated, breaks=breaks, labels=labels)),
#              color='black', pch=21, size = 2.5) +
#   scale_fill_brewer(palette='RdYlBu', guide = guide_legend(reverse=TRUE), name='')+
#   labs(title='Uncalibrated PCR-GLOBWB\n') +
#   xlab('longitude')+
#   ylab('latitude') +
#   theme(plot.title = element_text(hjust = 0.5, size=20),
#         axis.title.x = element_blank(),
#         axis.title.y = element_blank(),
#         axis.ticks = element_blank(),
#         panel.grid = element_blank())

KGE_map_meteoCatchAttr <- ggplot() +
  geom_map(
    data = wg, map = wg,
    aes(long, lat, map_id = region),
    color = "white", fill= "grey"
  ) +
  theme_map()+
  xlim(-180,180)+
  ylim(-55,75)+
  geom_point(plotData_meteoCatchAttr, mapping = aes(x = lon, y = lat,
                                                  fill=cut(mean_test_KGE_meteoCatchAttr, breaks=breaks, labels=labels)),
             color='black', pch=21, size = 2.5) +
  scale_fill_brewer(palette='RdYlBu', guide = guide_legend(reverse=TRUE), name='')+
  labs(title='Fully RF-based streamflow prediction (meteoCatchAttr)\n') +
  xlab('longitude')+
  ylab('latitude') +
  theme(plot.title = element_text(hjust = 0.5, size=20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

KGE_map_allpredictors <- ggplot() +
  geom_map(
    data = wg, map = wg,
    aes(long, lat, map_id = region),
    color = "white", fill= "grey"
  ) +
  theme_map()+
  xlim(-180,180)+
  ylim(-55,75)+
  geom_point(plotData_allpredictors, mapping = aes(x = lon, y = lat,
                                                  fill=cut(mean_test_KGE_allpredictors, breaks=breaks, labels=labels)),
             color='black', pch=21, size = 2.5) +
  scale_fill_brewer(palette='RdYlBu', guide = guide_legend(reverse=TRUE), name='') +
labs(title="Hybrid streamflow prediction (allPredictors)\n") +
  xlab('longitude')+
  ylab('latitude') +
  theme(plot.title = element_text(hjust = 0.5, size=20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

#patch it 
combined <- ( KGE_map_meteoCatchAttr / KGE_map_allpredictors ) + 
  plot_layout(guides = "collect", width=c(2,2)) &
  guides(fill = guide_legend(override.aes = list(size = 7))) &
  theme(legend.position = 'bottom',
        legend.title = element_text(size=16),
        legend.text = element_text(size=16))
combined

# save
# ggsave(paste0(outputDir,'map_kge_benchmark.png'), combined, height=15, width=15, units='in', dpi=1200)



#### scatterplot KGE uncalibrated vs. allpredictors ####
# scatterData <- merge(plotData_uncalibrated, plotData_allpredictors, by='grdc_no')
# 
# ggplot(scatterData) +
#   geom_point(aes(x = mean_test_KGE_uncalibrated, y = mean_test_KGE_allpredictors)) #+
#   # xlim(-1,1)+
#   # ylim(-1,1)
# rsq <- function (x, y) cor(x, y) ^ 2
# rsq(scatterData$mean_test_KGE_uncalibrated, scatterData$mean_test_KGE_allpredictors)


#performance: improved or degraded KGE
eval_allG <- inner_join(plotData_uncalibrated,plotData_allpredictors, by='grdc_no')

improvement <- eval_allG[which(eval_allG$mean_test_KGE_uncalibrated < eval_allG$mean_test_KGE_allpredictors),]
worsening <-   eval_allG[which(eval_allG$mean_test_KGE_uncalibrated > eval_allG$mean_test_KGE_allpredictors),]

summary(worsening$mean_test_KGE_uncalibrated)
summary(worsening$mean_test_KGE_allpredictors)
summary(improvement$mean_test_KGE_uncalibrated)
summary(improvement$mean_test_KGE_allpredictors)

summary(worsening$miss.x)
summary(improvement$miss.x)




