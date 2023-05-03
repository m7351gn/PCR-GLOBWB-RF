####-------------------------------####
source('../fun_0_loadLibrary.R')
####-------------------------------####

stationInfo <- read.csv('../../../data/stationLatLon.csv') %>%
  select(., grdc_no, lon, lat, miss, area) %>% 
  mutate(available=100-miss)

outputDir <- paste0('../../../viz/')
dir.create(outputDir, showWarnings = F, recursive = T)

wg <- map_data("world")
stations_xy <- stationInfo %>% select(grdc_no, lat, lon)

myPalette <- colorRampPalette((brewer.pal(9, "RdYlBu")))
sc <- scale_fill_gradientn(colours = myPalette(100), limits=c(0,100), 
                           breaks=c(0,50,100), name='Available data (%)')

missing_map <- ggplot() +
  geom_map(
    data = wg, map = wg,
    aes(long, lat, map_id = region),
    color = "white", fill= "grey"
  ) +
  theme_map()+
  xlim(-180,180)+
  ylim(-55,75)+
  geom_point(stationInfo, mapping = aes(x = lon, y = lat,  fill=available,  size = area),
             color='black', pch=21, alpha=0.8) +
  sc+
  theme(legend.title = element_text(size=20),
        legend.text = element_text(size = 16),
        legend.direction = 'horizontal',
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())+
  scale_size(name=expression(paste("Upstream area ", "(km"^"2",")")),
             breaks=c(10000,100000,500000,1000000,4680000),
             labels=c('asd','10 000 < A < 100 000',
                      '100 000 < A < 500 000', '500 000 < A < 1 000 000 ',
                      '1 000 000 < A < 4 680 000'),
             range=c(2,8))+
  guides(size=guide_legend(direction='vertical'))
  
missing_map


ggsave(paste0(outputDir,'map_miss.png'), missing_map, height=7, width=14, units='in', dpi=600, bg='white')

