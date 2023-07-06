# overview of data

library(tidyverse)
library(gtsummary)
library(flextable)
# library(ggplot2)


tibble(ll = readLines("data-raw/datasets-cmip5-with-files-and-size.txt")) %>%
  separate(ll, c("dataset_id", "esgf_node", "filename", "size"), sep = "[|]") %>% 
  mutate(filename2 = str_sub(filename, end = -4)) %>% 
  separate(filename2,
           c("variable", "time_frequency", "gcm", "experiment", "ensemble", "period"), 
           sep = "[_]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB = size_byte/1024/1024/1024) -> dat_cmip5_size



# tables ------------------------------------------------------------------

dat_cmip5_size %>% 
  group_by(gcm, experiment, ensemble, variable) %>% 
  summarise(size_GB = sum(size_GB)) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-cmip5-01-all.html")


dat_cmip5_size %>% 
  group_by(gcm, experiment, ensemble, variable) %>% 
  summarise(size_GB = sum(size_GB)) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = variable) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-cmip5-02-by-variable.html")


dat_cmip5_size %>% 
  filter(variable %in% c("tas", "tasmin", "tasmax", "pr")) %>% 
  group_by(gcm, experiment, ensemble, variable) %>% 
  summarise(size_GB = sum(size_GB)) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-cmip5-03-only-taspr.html")


dat_cmip5_size %>% 
  filter(variable %in% c("tas", "tasmin", "tasmax", "pr")) %>% 
  group_by(gcm, experiment, ensemble, variable) %>% 
  summarise(size_GB = sum(size_GB)) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = gcm) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-cmip5-04-only-taspr-by-gcm.html")



