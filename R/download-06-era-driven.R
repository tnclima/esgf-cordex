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
  filter(experiment == "evaluation", variable %in% c("pr", "tas", "tasmin", "tasmax"))

dat_todo <- dat1 %>% 
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name))

data.table::fwrite(dat_todo, "data-raw/to-download7-era-driven.csv")
