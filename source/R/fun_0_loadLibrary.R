print('loading packages...')
pacman::p_load("tidyverse", "gridExtra", "naniar", "lubridate", "sjmisc", #data 
               "RColorBrewer", "ggmap", "maps", "rcartocolor", "ggthemes",
               "ggrepel", "ggpmisc", "patchwork", "ggcorrplot",# viz 
               "ranger", "hydroGOF", # random forest, xbooost and KGE
               "doParallel", "foreach", "parallel", #parallel
               "vroom")
