# overview of data

library(tidyverse)
library(gtsummary)
library(flextable)
library(stringr)
# library(ggplot2)

tibble(ll = readLines("data-raw/datasets-cordex-full.txt")) %>% 
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") -> dat_cordex

dat1 <- dat_cordex %>% 
  filter(experiment %in% c("historical", "rcp85"), 
         variable %in% c("snc", "snw", 
                         "rsds", "rsus", "rlds", "rlus",
                         "huss", "hfls", "hfss",
                         "clt", "cll", "clm", "clh",
                         "ts")) %>% 
  filter(! rcm_name %in% c("ALARO-0", "RegCM4-2", "WRF361H", "ALADIN53"))

dat_todo <- dat1 %>% 
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name))

data.table::fwrite(dat_todo, "data-raw/to-download8-drivers.csv")
