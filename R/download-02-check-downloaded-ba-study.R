# check the downloaded files

library(eurocordexr)
library(tidyverse)
library(fs)

# downloaded --------------------------------------------------------------

dat_inv <- get_inventory("/home/climatedata/eurocordex/")
dat_inv_files <- get_inventory("/home/climatedata/eurocordex/", add_files = T)
dat_inv

dat_check <- check_inventory(dat_inv)
dat_check

# remove duplicate ensemble MPI-CSC-REMO2009
# dat_check$multiple_ensembles %>% 
#   merge(dat_inv_files[ensemble == "r1i1p1"]) -> dat_remove
# dat_remove$list_files %>% unlist -> files_old
# files_new <- path("/home/climatedata/eurocordex-temp2/", path_file(files_old))
# file_move(files_old, files_new)


dat_inv[, .N, institute_rcm]  
# dat_inv[institute_rcm == "CNRM-ARPEGE51"] # -> maybe remove?
# dat_inv[institute_rcm == "MOHC-HadREM3-GA7-05"] # -> maybe remove?

dat_inv[, .N, experiment]
dat_inv[experiment == "rcp26"]
dat_inv[experiment == "evaluation"]
# -> focus on rcp45 and rcp85?

dat_inv[, .N, .(variable, gcm, institute_rcm)]



# check orog --------------------------------------------------------------

dat_inv[variable == "orog", institute_rcm] 
dat_inv[variable != "orog", .N, institute_rcm] 


# check availability of adj and raw ---------------------------------------

# dat_comp <- compare_variables_in_inventory(dat_inv, c("pr", "prAdjust"))

dat_ba <- copy(dat_inv)
dat_ba[, .N, downscale_realisation] 
dat_ba[ , ds_ba := downscale_realisation] 
dat_ba[downscale_realisation %in% c("v1", "v1a", "v2"), ds_ba := "raw"]


dat_comp <- dat_ba[experiment != "historical" & variable %in% c("pr", "prAdjust")] %>% 
  dcast(gcm + institute_rcm + experiment + ensemble ~ ds_ba,
        value.var = "domain")







