# check the downloaded files

library(eurocordexr)
setDTthreads(2)
library(tidyverse)
library(fs)

# downloaded --------------------------------------------------------------

# raw & adjust

dat_inv <- get_inventory("/home/climatedata/eurocordex/merged/")
dat_inv

dat_check <- check_inventory(dat_inv)
dat_check


# rest of raw
dat_inv2 <- get_inventory("/home/climatedata/eurocordex2-rest/merged/")
dat_inv2

dat_check2 <- check_inventory(dat_inv2)
dat_check2

# orog
dat_inv_orog <- rbind(
  get_inventory("/home/climatedata/eurocordex2-rest/orog/"),
  get_inventory("/home/climatedata/eurocordex/orog/")
)


# get common adjust and raw -------------------------------------------

# with size (not updated)
# tibble(ll = readLines("data-raw/datasets-cordex-full.txt")) %>%
#   separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>%
#   separate(zz, c("project", "product", "domain", "institute",
#                  "driving_model", "experiment", "ensemble",
#                  "rcm_name", "rcm_version", "time_frequency",
#                  "variable", "version"), sep = "[.]") %>% 
#   mutate(size_byte = as.numeric(size),
#          size_GB_europe = size_byte/1024/1024/1024,
#          size_GB_GAR = size_GB_europe/20) -> dat_esgf_raw

# without size
tibble(ll = readLines("data-raw/datasets-cordex-full.txt")) %>%
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]") -> dat_esgf_raw

tibble(ll = readLines("data-raw/datasets-cordex-adjust-with-size.txt")) %>% 
  separate(ll, c("zz", "esgf_node", "size"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") %>% 
  mutate(size_byte = as.numeric(size),
         size_GB_europe = size_byte/1024/1024/1024,
         size_GB_GAR = size_GB_europe/20) -> dat_esgf_adjust

# merge and subset
# dat_esgf <- rbind(dat_esgf_raw, dat_esgf_adjust) %>% as.data.table
# dat_esgf <- dat_esgf[startsWith(variable, "pr") | startsWith(variable, "tas") ] 
# dat_esgf[, institute_rcm := paste0(institute, "-", rcm_name)]  
# dat_esgf[, .N, institute_rcm] 
# with(dat_esgf, table(institute_rcm, variable))

# take only models with adjust
dat_esgf_adjust %>% 
  filter(variable != "sfcWindAdjust") %>% 
  select(institute:rcm_name, variableAdjust = variable) %>% 
  mutate(variable = str_remove(variableAdjust, "Adjust")) %>% 
  unique -> dat_esgf_adjust_gcmrcm


dat_adj_raw <- dat_esgf_adjust_gcmrcm %>% semi_join(dat_esgf_raw)

dat_esgf_adjust_gcmrcm %>% anti_join(dat_esgf_raw)

# compare to downloaded ---------------------------------------------------

dat_adj_raw %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  rename(gcm = driving_model) %>% 
  # anti_join(dat_inv) -> dat_zz
  semi_join(dat_inv) -> dat_zz

# RCA4 is missing from normal cordex!


dat_esgf_adjust %>% 
  filter(variable != "sfcWindAdjust") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  anti_join(dat_inv) -> dat_zz
  # semi_join(dat_inv) -> dat_zz


# some missing



# create list to download -------------------------------------------------

# dat_adj_raw %>%
#   rbind(mutate(dat_adj_raw, experiment = "historical")) %>%
#   select(-variableAdjust) %>%
#   unique %>%
#   mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>%
#   rename(gcm = driving_model) %>%
#   anti_join(dat_inv) -> dat_todo1
# 
# fwrite(dat_todo1, "data-raw/to-download1-adjraw-raw.csv")

dat_esgf_raw %>%
  filter(variable %in% c("pr", "tas", "tasmin", "tasmax")) %>% 
  filter(experiment != "evaluation") %>% 
  right_join(dat_adj_raw) %>%
  filter(rcm_name != "REMO2009") %>% # done separately!
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>%
  anti_join(dat_inv) -> dat_todo1

fwrite(dat_todo1, "data-raw/to-download1-adjraw1-raw.csv")

dat_esgf_adjust %>% 
  filter(variable != "sfcWindAdjust") %>% 
  right_join(dat_adj_raw %>% mutate(variable = variableAdjust)) %>% 
  # filter(! rcm_name %in% c("ARPEGE51", "WRF331")) %>% # no raw available
  filter(rcm_name != "REMO2009") %>% # done separately!
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  anti_join(dat_inv) -> dat_todo2

fwrite(dat_todo2, "data-raw/to-download1-adjraw2-adj.csv")




# redo remo because of grid +0.55 deg -------------------------------------


dat_esgf_raw %>% 
  filter(variable %in% c("pr", "tas", "tasmin", "tasmax")) %>% 
  filter(experiment != "evaluation") %>% 
  filter(rcm_name == "REMO2009") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model, downscale_realisation = rcm_version) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  anti_join(dat_inv) -> dat_todo3

fwrite(dat_todo3, "data-raw/to-download5-remo1-raw.csv")

dat_esgf_adjust %>% 
  filter(variable != "sfcWindAdjust") %>% 
  filter(rcm_name == "REMO2009") %>% 
  select(institute:rcm_version, variable) %>% 
  rename(gcm = driving_model, downscale_realisation = rcm_version) %>% 
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>% 
  anti_join(dat_inv) -> dat_todo4

fwrite(dat_todo4, "data-raw/to-download5-remo2-adj.csv")





# rest of ensemble for temp precip ----------------------------------------


dat_esgf_raw %>%
  filter(variable %in% c("tas", "tasmin", "tasmax", "pr")) %>% 
  filter(experiment != "evaluation") %>% 
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>%
  filter(! institute_rcm %in% c("UHOH-WRF361H", "DHMZ-RegCM4-2", "CNRM-ALADIN53")) %>% 
  # potentially also remove RMIB-UGent-ALARO-0, ICTP-RegCM4-6
  anti_join(dat_inv) -> dat_todo_rest

fwrite(dat_todo_rest, "data-raw/to-download2-rest-ensemble.csv")



# rest of ensemble orog ----------------------------------------



tibble(ll = readLines("data-raw/datasets-cordex-fx.txt")) %>%
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>%
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency",
                 "variable", "version"), sep = "[.]")  -> dat_esgf_fx



dat_esgf_fx %>% 
  filter(variable == "orog") %>% 
  group_by(rcm_name) %>% 
  slice_head(n = 1) %>% 
  
  select(institute:rcm_version, variable) %>%
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>%
  # filter(! institute_rcm %in% c("UHOH-WRF361H", "DHMZ-RegCM4-2", "CNRM-ALADIN53")) %>% 
  # potentially also remove RMIB-UGent-ALARO-0, ICTP-RegCM4-6
  anti_join(dat_inv_orog) -> dat_todo_fx

fwrite(dat_todo_fx, "data-raw/to-download2-rest-ensemble-orog.csv")



# missing historical in rest of raw ---------------------------------------

dat_scen <- dat_check2$missing_historical[, 
                                          .(variable, domain, gcm, institute_rcm, experiment,
                                            ensemble, downscale_realisation, timefreq)]
dat_scen %>% with(table(variable, paste0(gcm, "_", institute_rcm)))
dat_scen2 <- unique(dat_scen[, !"experiment"])

dat_esgf_raw %>% 
  filter(experiment == "historical") %>% 
  rename(gcm = driving_model,
         downscale_realisation = rcm_version) %>%
  mutate(institute_rcm = paste0(institute, "-", rcm_name)) %>%
  right_join(dat_scen2[variable == "pr"]) -> dat_zz
  # inner_join(dat_scen2[variable == "pr"]) -> dat_zz






