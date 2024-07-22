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

pvars <- lapply(c("hus", "ta", "ua", "va"), \(x) str_c(x, c(1:7*100, 850, 925))) %>% unlist
other_vars <- c("rsds", "rlds", "pr")
dat_sub <- dat_cordex %>% 
  filter(variable %in% c(pvars, other_vars)) 

dat1 <- dat_sub %>% 
  filter(rcm_name == "ALADIN63",
         driving_model == "CNRM-CERFACS-CNRM-CM5",
         experiment %in% c("historical", "rcp85"))

dat2 <- dat_sub %>% 
  filter(rcm_name == "RegCM4-6",
         driving_model == "NCC-NorESM1-M",
         experiment %in% c("historical", "rcp85"))


dat3 <- dat_sub %>% 
  filter(rcm_name == "REMO2015",
         driving_model == "NCC-NorESM1-M",
         experiment %in% c("historical", "rcp85"),
         str_starts(variable, "ta") | variable == "pr")

dat_todo <- rbind(dat1, dat2, dat3) %>% 
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name))

data.table::fwrite(dat_todo, "data-raw/to-download6-preslev.csv")
