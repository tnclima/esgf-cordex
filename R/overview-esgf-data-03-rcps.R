# overview of data

library(tidyverse)
library(gtsummary)
library(flextable)
# library(ggplot2)

tibble(ll = readLines("data-raw/datasets-cordex-full.txt")) %>% 
  separate(ll, c("zz", "esgf_node"), sep = "[|]") %>% 
  separate(zz, c("project", "product", "domain", "institute",
                 "driving_model", "experiment", "ensemble",
                 "rcm_name", "rcm_version", "time_frequency", 
                 "variable", "version"), sep = "[.]") -> dat_cordex


# tas ---------------------------------------------------------------------


dat_cordex %>% 
  filter(variable == "tas" & experiment != "evaluation" & experiment != "historical") %>% 
  select(rcm_name, driving_model, ensemble, experiment) %>% 
  mutate(avail = "x") %>% 
  pivot_wider(names_from = experiment, values_from = avail) %>% 
  arrange(rcm_name, driving_model, ensemble) %>% 
  relocate(rcp85, .after = rcp45) %>% 
  mutate(both_45_85 = if_else(rcp85 == "x" & rcp45 == "x", "x", ""),
         both_26_85 = if_else(rcp85 == "x" & rcp26 == "x", "x", ""),
         all_three = if_else(rcp85 == "x" & rcp45 == "x" & rcp26 == "x", "x", "")) -> dat_rcp


# manually remove multiple ensembles
dat_rcp %>% 
  group_by(rcm_name, driving_model) %>% 
  summarise(nn = n()) %>% 
  filter(nn > 1)

dat_rcp %>% filter(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "MPI-M-MPI-ESM-LR")
dat_rcp %>% filter(rcm_name == "HIRHAM5" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RACMO22E" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RCA4" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RCA4" & driving_model == "MPI-M-MPI-ESM-LR")
dat_rcp %>% filter(rcm_name == "REMO2009" & driving_model == "MPI-M-MPI-ESM-LR")

dat_rcp2 <- dat_rcp %>% 
  filter(!(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r12i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r1i1p1", "r2i1p1"))) %>% 
  filter(!(rcm_name == "HIRHAM5" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r12i1p1", "r1i1p1"))) %>% 
  filter(!(rcm_name == "RACMO22E" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r1i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "RCA4" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r1i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "RCA4" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r2i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "REMO2009" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r1i1p1"))) 
  

dat_rcp2 %>% 
  flextable() %>% 
  autofit()

ft <- dat_rcp2 %>% 
  summarise(across(rcp26:all_three, ~ as.character(sum(.x == "x", na.rm = T)))) %>% 
  bind_rows(dat_rcp2, .) %>% 
  flextable %>% 
  autofit()

save_as_html(ft, path = "tables/rcp-01-tas.html")



# tasmin tasmax pr --------------------------------------------------------


dat_cordex %>% 
  filter(experiment != "evaluation" & experiment != "historical") %>% 
  filter(variable %in% c("tasmin", "tasmax", "pr")) %>% 
  pivot_wider(names_from = variable, values_from = variable) %>% 
  # summarise(across(tasmin:pr, ~ sum(is.na(.x))))
  drop_na() %>% 
  select(rcm_name, driving_model, ensemble, experiment) %>% 
  mutate(avail = "x") %>% 
  pivot_wider(names_from = experiment, values_from = avail) %>% 
  arrange(rcm_name, driving_model, ensemble) %>% 
  relocate(rcp85, .after = rcp45) %>% 
  mutate(both_45_85 = if_else(rcp85 == "x" & rcp45 == "x", "x", ""),
         both_26_85 = if_else(rcp85 == "x" & rcp26 == "x", "x", ""),
         all_three = if_else(rcp85 == "x" & rcp45 == "x" & rcp26 == "x", "x", "")) -> dat_rcp


# manually remove multiple ensembles
dat_rcp %>% 
  group_by(rcm_name, driving_model) %>% 
  summarise(nn = n()) %>% 
  filter(nn > 1)

dat_rcp %>% filter(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "MPI-M-MPI-ESM-LR")
dat_rcp %>% filter(rcm_name == "HIRHAM5" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RACMO22E" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RCA4" & driving_model == "ICHEC-EC-EARTH")
dat_rcp %>% filter(rcm_name == "RCA4" & driving_model == "MPI-M-MPI-ESM-LR")
dat_rcp %>% filter(rcm_name == "REMO2009" & driving_model == "MPI-M-MPI-ESM-LR")

dat_rcp2 <- dat_rcp %>% 
  filter(!(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r12i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "COSMO-crCLIM-v1-1" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r1i1p1", "r2i1p1"))) %>% 
  filter(!(rcm_name == "HIRHAM5" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r12i1p1", "r1i1p1"))) %>% 
  filter(!(rcm_name == "RACMO22E" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r1i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "RCA4" & driving_model == "ICHEC-EC-EARTH" & ensemble %in% c("r1i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "RCA4" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r2i1p1", "r3i1p1"))) %>% 
  filter(!(rcm_name == "REMO2009" & driving_model == "MPI-M-MPI-ESM-LR" & ensemble %in% c("r1i1p1"))) 



ft2 <- dat_rcp2 %>% 
  summarise(across(rcp26:all_three, ~ as.character(sum(.x == "x", na.rm = T)))) %>% 
  bind_rows(dat_rcp2, .) %>% 
  flextable %>% 
  autofit()

save_as_html(ft2, path = "tables/rcp-02-tasmin-tasmax-pr.html")
