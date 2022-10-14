# overview of data

library(tidyverse)
library(gtsummary)
library(flextable)
# library(ggplot2)

tibble(ll = readLines("data-raw/datasets-cordex.txt")) %>% 
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") -> dat_cordex

dat_cordex %>% 
  select(driving_model, experiment, rcm_name, variable) %>% 
  tbl_summary()# %>%
  # as_gt() %>% 
  # gt::gtsave("tables/cordex-overview.html")

# dat_cordex %>% 
#   select(driving_model, experiment, rcm_name, variable) %>% 
#   tbl_summary() %>% 
#   as_flex_table() %>% 
#   save_as_docx(path = "tables/cordex-overview.docx")
  

tibble(ll = readLines("data-raw/datasets-cordex-adjust.txt")) %>% 
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") -> dat_cordex_adjust

dat_cordex_adjust %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version) %>% 
  tbl_summary(statistic = list(all_categorical() ~ "{n}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-01-adjust.html")


dat_cordex_adjust %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version) %>% 
  tbl_summary(by = rcm_version,
              statistic = list(all_categorical() ~ "{n}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-02-adjust-by-rcm-version.html")

dat_cordex_adjust %>% 
  select(driving_model, experiment, rcm_name, variable, rcm_version) %>% 
  tbl_summary(by = driving_model,
              statistic = list(all_categorical() ~ "{n}")) %>% 
  as_gt() %>% 
  gt::gtsave("tables/esgf-overview-03-adjust-by-driving-model.html")




# file sizes --------------------------------------------------------------


# adjust 


tibble(ll = readLines("data-raw/datasets-cordex-adjust-with-size.txt")) %>% 
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB = size_byte/1024/1024/1024) -> dat_cordex_adjust_size

dat_cordex_adjust_size %>% 
  select(variable, size_GB) %>% 
  tbl_summary(statistic = list(all_continuous() ~ "{sum}"))

dat_cordex_adjust_size %>% 
  select(variable, size_GB) %>% 
  tbl_summary(statistic = list(all_continuous() ~ "{sum}"),
              by = variable)


