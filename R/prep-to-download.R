# prep files to download from esgf

library(eurocordexr)
library(tidyverse)


# overview esgf -----------------------------------------------------------

tibble(ll = readLines("data-raw/datasets-cordex-with-size.txt")) %>%
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_esgf

tibble(ll = readLines("data-raw/datasets-cordex-adjust-with-size.txt")) %>% 
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_esgf_adjust

tibble(ll = readLines("data-raw/datasets-cordex-full.txt")) %>%
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]") -> dat_esgf_full


# ba study ----------------------------------------------------------------


# orog
dat_esgf_adjust$rcm_name %>% table

# remove rcms which do not have raw data and subset to 1/rcm
dat_esgf_adjust %>% 
  filter(! rcm_name %in% c("ARPEGE51", "WRF331F")) %>% 
  select(institute:rcm_name) %>% 
  unique %>% 
  group_by(rcm_name) %>% 
  filter(row_number() == 1) -> dat_orog_adjust

fwrite(dat_orog_adjust, "data-raw/to-download3_orog.csv")

# swe
dat_esgf_adjust %>% 
  filter(! rcm_name %in% c("ARPEGE51", "WRF331F")) %>% 
  select(institute:rcm_name) %>% 
  unique %>% 
  left_join(dat_esgf_full %>% filter(variable == "snw")) -> dat_snw_adjust

# rca4 does not have snw
# maybe replace with snd as proxy? other models do not have snd

# dont forget to add historical!

# rest of ensemble --------------------------------------------------------

dat_esgf_adjust %>% 
  filter(! rcm_name %in% c("ARPEGE51", "WRF331F")) %>% 
  select(institute:rcm_name) %>% 
  unique -> dat_ba

dat_ba <- rbind(dat_ba,
                mutate(dat_ba, experiment = "historical"))

# temp and prec
dat_esgf %>% 
  filter(variable %in% c("tas", "tasmax", "tasmin", "pr")) %>% 
  anti_join(dat_ba) -> dat_ensemble_rest

# check
dat_ensemble_rest$experiment %>% table
dat_ensemble_rest$rcm_name %>% table

dat_esgf %>% filter(rcm_name == "RegCM4-2")
dat_esgf %>% filter(rcm_name == "ALARO-0")
dat_esgf %>% filter(rcm_name == "WRF361H")
dat_esgf %>% filter(rcm_name == "CCLM4-8-17")
dat_esgf %>% filter(rcm_name == "ALADIN53")
dat_esgf %>% filter(rcm_name == "REMO2009")

# remove a few rcms and do not use version
dat_ensemble_rest %>% 
  filter(! rcm_name %in% c("ALARO-0", "RegCM4-2", "WRF361H")) %>% 
  select(institute:variable) %>% 
  unique -> dat_ensemble_rest2

fwrite(dat_ensemble_rest2, "data-raw/to-download4_rest_ensemble.csv")

