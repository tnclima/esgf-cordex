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

dat_cordex %>% 
  filter(variable %in% pvars) %>% 
  select(driving_model, experiment, rcm_name, variable) %>% 
  tbl_summary(by = variable, include = rcm_name,
              statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}")) %>%
  as_gt() %>%
  gt::gtsave("tables/esgf-overview-09-pressure-levels.html")

# dat_cordex %>% 
#   select(driving_model, experiment, rcm_name, variable) %>% 
#   tbl_summary() %>% 
#   as_flex_table() %>% 
#   save_as_docx(path = "tables/cordex-overview.docx")
  
