# merge extracted data
library(foreach)
library(data.table)
library(fs)
library(stringr)

path_out <- "data-extract/mg-export/"


dir_stns <- dir_ls("data-extract/mg/", type = "directory")


foreach(
  i_dir_stn = dir_stns
) %do% {
  
  dir_vars <- dir_ls(i_dir_stn)
  
  # orog --------------------------------------------------------------------
  

  dir_orog <- str_subset(dir_vars, "orog")
  
  dat_orog <- foreach(
    fn = list.files(dir_orog, full.names = T, recursive = F),
    .final = rbindlist
  ) %do% {
    
    dat <- readRDS(fn)
    fn_split <- strsplit(fn %>% path_file() %>% path_ext_remove(), "_")[[1]]
    dir_split <- strsplit(dirname(fn), "/")[[1]]
    
    dat[, ":="(stn = tail(dir_split, 2)[1],
               gcm = fn_split[1],
               rcm = fn_split[2],
               experiment = fn_split[3],
               ensemble = fn_split[4],
               rcm_version = fn_split[5])]
    
    # remove columns if orog, so merge works
    if(tail(dir_split, 1) == "orog"){
      dat <- dat[, .(orog, stn, rcm)]   
    }  
    
    dat
    
  }
  
  
  # raw data ----------------------------------------------------------------
  
  dir_raw <- str_subset(dir_vars, "orog|Adjust", negate = T)
  
  
  dat_raw <- foreach(
    i_dir_stn_var = dir_raw,
    .final = function(l) Reduce(merge, l)
  ) %do% {
    
    foreach(
      fn = list.files(i_dir_stn_var, full.names = T, recursive = F),
      .final = rbindlist
    ) %do% {
      
      dat <- readRDS(fn)
      fn_split <- strsplit(fn %>% path_file() %>% path_ext_remove(), "_")[[1]]
      dir_split <- strsplit(dirname(fn), "/")[[1]]
      
      dat[, ":="(stn = tail(dir_split, 2)[1],
                 gcm = fn_split[1],
                 rcm = fn_split[2],
                 experiment = fn_split[3],
                 ensemble = fn_split[4],
                 rcm_version = fn_split[5])]
      
      dat
      
    }
    
  }
  
  
  # adjusted data -----------------------------------------------------------
  
  dir_adj <- str_subset(dir_vars, "Adjust")
  
  
  dat_adj <- foreach(
    i_dir_stn_var = dir_adj,
    .final = function(l) Reduce(merge, l)
  ) %do% {
    
    foreach(
      fn = list.files(i_dir_stn_var, full.names = T, recursive = F),
      .final = rbindlist
    ) %do% {
      
      dat <- readRDS(fn)
      fn_split <- strsplit(fn %>% path_file() %>% path_ext_remove(), "_")[[1]]
      dir_split <- strsplit(dirname(fn), "/")[[1]]
      
      dat[, ":="(stn = tail(dir_split, 2)[1],
                 gcm = fn_split[1],
                 rcm = fn_split[2],
                 experiment = fn_split[3],
                 ensemble = fn_split[4],
                 rcm_version = fn_split[5])]
      
      dat
      
    }
    
  }
  
  
  # check number of gcm-rcm -------------------------------------------------
  
  # dat_raw[, .N, .(gcm, rcm, experiment)]
  # 
  # # remove duplicated ensemble 
  # dat_raw <- dat_raw[!(gcm == "MPI-M-MPI-ESM-LR" & rcm == "MPI-CSC-REMO2009" & ensemble == "r1i1p1")] 
  # dat_raw[, .N, .(gcm, rcm, experiment)]
  # 
  # dat_adj[, .N, .(gcm, rcm, experiment, rcm_version)]
  # dat_adj[gcm == "CNRM-CERFACS-CNRM-CM5" & rcm == "CLMcom-CCLM4-8-17" & 
  #           experiment == "rcp45" & rcm_version == "v1-IPSL-CDFT22s-MESAN-1989-2005"] 
  
  # convert and export --------------------------------------------------------
  
  # deg C and mm
  dat_raw[, ":="(pr = pr * 24*60*60, 
                 tas = tas - 273.15,
                 tasmin = tasmin - 273.15,
                 tasmax = tasmax - 273.15)]
  dat_adj[, ":="(prAdjust = prAdjust * 24*60*60, 
                 tasAdjust = tasAdjust - 273.15,
                 tasminAdjust = tasminAdjust - 273.15,
                 tasmaxAdjust = tasmaxAdjust - 273.15)]
  
  dir_create(path(path_out, path_file(i_dir_stn)))
  
  fwrite(dat_orog, file = path(path_out, path_file(i_dir_stn), "elevation.csv"))
  fwrite(dat_raw, file = path(path_out, path_file(i_dir_stn), "rcm-raw.csv"))
  fwrite(dat_adj, file = path(path_out, path_file(i_dir_stn), "rcm-adjusted.csv"))
  
}

