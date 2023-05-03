ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, repos='http://cran.us.r-project.org')
}

packages <- c("tidyverse", "gridExtra", "naniar", "lubridate", "sjmisc", #data 
              "RColorBrewer", "ggmap", "maps", "rcartocolor", "ggthemes",
              "ggrepel", "ggpmisc", "patchwork", "corrplot", 'ggh4x', # viz 
              "ranger", "hydroGOF",# random forest and KGE
              "doParallel", "foreach", "parallel", #parallel
              "vroom", "pacman"# misc
              )

ipak(packages)