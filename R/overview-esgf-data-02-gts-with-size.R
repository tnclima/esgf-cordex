# overview of data

# grid size EUR-11 412x421
# GAR: ~8000
# -> factor of ~ 20

library(tidyverse)
library(gtsummary)
library(flextable)
# library(ggplot2)


# all euro-cordex ---------------------------------------------------------



tibble(ll = readLines("data-raw/datasets-cordex-with-size.txt")) %>%
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_cordex_size

dat_cordex_size %>% 
  select(driving_model, experiment, rcm_name, variable,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-05-original.html")


dat_cordex_size %>% 
  select(driving_model, experiment, rcm_name, variable,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = variable) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-06-original-by-variable.html")



dat_cordex_size %>% 
  select(driving_model, experiment, rcm_name, variable, 
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = rcm_name) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-07-original-by-rcm-name.html")


dat_cordex_size %>% 
  select(driving_model, experiment, rcm_name, variable, 
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = driving_model) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-08-original-by-driving-model.html")



# adjust ------------------------------------------------------------------




tibble(ll = readLines("data-raw/datasets-cordex-adjust-with-size.txt")) %>% 
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_cordex_adjust_size

dat_cordex_adjust_size %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-01-adjust.html")


dat_cordex_adjust_size %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = variable) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-02-adjust-by-variable.html")



dat_cordex_adjust_size %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = rcm_version) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-03-adjust-by-rcm-version.html")


dat_cordex_adjust_size %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version,
         size_GB_europe, size_GB_GAR) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}",
                               all_continuous() ~ "{sum}"),
              by = driving_model) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-04-adjust-by-driving-model.html")







