# check the downloaded files

library(eurocordexr)
library(tidyverse)
library(fs)

# downloaded --------------------------------------------------------------

dat_inv <- get_inventory("/home/climatedata/eurocordex/merged/")
dat_inv_files <- get_inventory("/home/climatedata/eurocordex/merged/", add_files = T)
dat_inv

dat_check <- check_inventory(dat_inv)
dat_check


# get common adjust and raw -------------------------------------------


tibble(ll = readLines("data-raw/datasets-cordex-with-size.txt")) %>%
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_esgf1

tibble(ll = readLines("data-raw/datasets-cordex-adjust-with-size.txt")) %>% 
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_esgf2

# merge and subset
# dat_esgf <- rbind(dat_esgf1, dat_esgf2) %>% as.data.table
# dat_esgf <- dat_esgf[startsWith(variable, "pr") | startsWith(variable, "tas") ] 
# dat_esgf[, institute_rcm := paste0(institute, "-", rcm_name)]  
# dat_esgf[, .N, institute_rcm] 
# with(dat_esgf, table(institute_rcm, variable))

# take only models with adjust
dat_esgf2 %>% 
  filter(variable != "sfcWindAdjust") %>% 
  select(institute:rcm_name, variableAdjust = variable) %>% 
  mutate(variable = str_remove(variableAdjust, "Adjust")) %>% 
  unique -> dat_esgf_adjust


dat_adj_raw <- dat_esgf_adjust %>% semi_join(dat_esgf1)


# compare to downloaded ---------------------------------------------------

dat_adj_raw %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  rename(gcm = driving_model) %>% 
  # anti_join(dat_inv) -> dat_zz
  semi_join(dat_inv) -> dat_zz

# RCA4 is missing from normal cordex!


dat_esgf2 %>% 
  filter(variable != "sfcWindAdjust") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  # anti_join(dat_inv) -> dat_zz
  semi_join(dat_inv) -> dat_zz


# some missing



# create list to download -------------------------------------------------

dat_adj_raw %>% 
  rbind(mutate(dat_adj_raw, experiment = "historical")) %>% 
  select(-variableAdjust) %>% 
  unique %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  rename(gcm = driving_model) %>% 
  anti_join(dat_inv) -> dat_todo1

fwrite(dat_todo1, "data-raw/to-download1.csv")

dat_esgf2 %>% 
  filter(variable != "sfcWindAdjust") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  anti_join(dat_inv) -> dat_todo2

fwrite(dat_todo2, "data-raw/to-download2.csv")




# redo remo because of grid +0.55 deg -------------------------------------


dat_esgf2 %>% 
  filter(variable != "sfcWindAdjust") %>% 
  filter(rcm_name == "REMO2009") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) -> dat_todo3

fwrite(dat_todo3, "data-raw/to-download5-remo1.csv")

dat_esgf1 %>% 
  filter(variable %in% c("pr", "tas", "tasmin", "tasmax")) %>% 
  filter(experiment != "evaluation") %>% 
  filter(rcm_name == "REMO2009") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) -> dat_todo4

fwrite(dat_todo4, "data-raw/to-download5-remo2.csv")





