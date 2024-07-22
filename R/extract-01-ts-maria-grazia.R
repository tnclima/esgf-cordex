# get timeseries for maria grazia

library(eurocordexr)
library(data.table)
setDTthreads(4)
library(ncdf4)
library(foreach)
library(fs)
library(magrittr)

path_out <- "data-extract/mg/"
path_out_export <- "data-extract/mg-export/"
dir_create(path_out)
dir_create(path_out_export)

dat_inv <- get_inventory("/home/climatedata/eurocordex2-rest/merged/")
dat_inv_orog <- get_inventory("/home/climatedata/eurocordex2-rest/orog/")

# sub-ensemble
dat_kkz <- readRDS("/home/michael.matiu/projects/downscaling/data/sub-ensemble-kkz-01-selected-models.rds")
dat_kkz_info <- readRDS("/home/michael.matiu/projects/downscaling/data/sub-ensemble-kkz-02-change-factors.rds")


dat_glacier <- fread("data-raw/maria_grazia_area_glacierinterest.csv")
lon <- mean(dat_glacier$X_wgs84_EPSG4326)
lat <- mean(dat_glacier$Y_wgs84_EPSG4326)


dat_extract <- data.table(stn = c("GlacierMariaGrazia", "GlacierMariaGrazia_south"),
                          lon = c(lon, lon),
                          lat = c(lat, lat-0.11))

# delete corrupt files ----------------------------------------------------

# dat_inv[249, list_files][[1]][2] %>% file.remove()

# check vertices ----------------------------------------------------------

file_rcm <- "/home/climatedata/eurocordex/merged/tas/tas_EUR-11_CNRM-CERFACS-CNRM-CM5_historical_r1i1p1_CLMcom-CCLM4-8-17_v1_day_19500101-20051231.nc"

dat_rcm_vert <- foreach(
  i = 1:nrow(dat_extract),
  .final = rbindlist
) %do% {
  
  filename = file_rcm
  variable = "tas"
  point_lon = dat_extract[i, lon]
  point_lat = dat_extract[i, lat]
  
  # from function
  ncobj <- nc_open(filename, readunlim = FALSE)
  grid_lon <- ncvar_get(ncobj, "lon")
  grid_lat <- ncvar_get(ncobj, "lat")
  grid_squared_dist <- (grid_lat - point_lat)^2 + (grid_lon - point_lon)^2
  cell_xy <- arrayInd(which.min(grid_squared_dist), dim(grid_squared_dist))
  
  grid_lon_vert <- ncvar_get(ncobj, "lon_bnds")
  grid_lat_vert <- ncvar_get(ncobj, "lat_bnds")
  data.table(stn = dat_extract[i, stn],
             lon = grid_lon_vert[, cell_xy[1], cell_xy[2]],
             lat = grid_lat_vert[, cell_xy[1], cell_xy[2]])
  
}


# dat_rcm_vert %>% 
#   ggplot(aes(lon, lat))+
#   geom_point()+
#   geom_point(data = dat_glacier, aes(X_wgs84_EPSG4326, Y_wgs84_EPSG4326), colour = "red")+
#   coord_equal()

fwrite(dat_rcm_vert, file = path(path_out_export, "rcm-vertices.csv"))




# create sub inv ----------------------------------------------------------


dat_kkz2 <- dat_kkz[experiment != "rcp26"]

dat_inv_sub <- rbind(
  dat_kkz2,
  dat_kkz2 %>% dplyr::mutate(experiment = "historical")
) %>% 
  merge(dat_inv[variable %in% c("tas", "pr")])


# sub inv change factors --------------------------------------------------


dat_delta <- dat_kkz_info %>% 
  merge(dat_kkz2, by = c("experiment", "centers"))

fwrite(dat_delta, file = path(path_out_export, "change-factors.csv"))



# extract all -------------------------------------------------------------

# mitmatmisc::init_parallel_ubuntu(8) # disk access is bottleneck


# extract data and save files

foreach(
  i_extract = 1:nrow(dat_extract)
) %do% {
  
  i_stn <- dat_extract[i_extract, stn]
  i_lon <- dat_extract[i_extract, lon]
  i_lat <- dat_extract[i_extract, lat]
  
  foreach(i_nc = 1:nrow(dat_inv_sub), .inorder = F) %dopar% {
    
    # create filename
    dat_inv_sub[i_nc, paste0(# variable, "_",
      gcm, "_",
      institute_rcm, "_",
      experiment, "_",
      ensemble, "_",
      downscale_realisation, ".rds")] %>% 
      # pre-append path
      path(path_out, 
           i_stn, 
           dat_inv_sub[i_nc, variable], 
           .) -> file_to_save
    
    # create directory and skip if file already exists
    if(!dir.exists(dirname(file_to_save))) dir.create(dirname(file_to_save), recursive = T)
    if(file.exists(file_to_save)) return(NULL)
    
    
    dat_nc <- rotpole_nc_point_to_dt(filename = dat_inv_sub[i_nc, list_files[[1]]],
                                     variable = dat_inv_sub[i_nc, variable],
                                     point_lon = i_lon,
                                     point_lat = i_lat,
                                     interpolate_to_standard_calendar = T,
                                     verbose = F)
    
    saveRDS(dat_nc,
            file = file_to_save)
    
    return(NULL)
  }
  
  return(NULL)
}


# orog --------------------------------------------------------------------

all_rcms <- dat_kkz2$institute_rcm %>% unique %>% sort

dat_inv_orog[institute_rcm == "UHOH-WRF361H", institute_rcm := "IPSL-WRF381P"]
dat_inv_orog_sub <- dat_inv_orog[institute_rcm %in% all_rcms]


foreach(
  i_extract = 1:nrow(dat_extract)
) %do% {
  
  i_stn <- dat_extract[i_extract, stn]
  i_lon <- dat_extract[i_extract, lon]
  i_lat <- dat_extract[i_extract, lat]
  
  foreach(i_nc = 1:nrow(dat_inv_orog_sub), .inorder = F) %do% {
    
    # create filename
    dat_inv_orog_sub[i_nc, paste0(# variable, "_",
      gcm, "_",
      institute_rcm, "_",
      experiment, "_",
      ensemble, "_",
      downscale_realisation, ".rds")] %>% 
      # pre-append path
      path(path_out, 
           i_stn, 
           dat_inv_orog_sub[i_nc, variable], 
           .) -> file_to_save
    
    # create directory and skip if file already exists
    if(!dir.exists(dirname(file_to_save))) dir.create(dirname(file_to_save), recursive = T)
    if(file.exists(file_to_save)) return(NULL)
    
    
    dat_nc <- rotpole_nc_point_to_dt(filename = dat_inv_orog_sub[i_nc, list_files[[1]]],
                                     # variable = dat_inv_sub[i_nc, variable],
                                     point_lon = i_lon,
                                     point_lat = i_lat,
                                     interpolate_to_standard_calendar = T,
                                     verbose = F)
    
    saveRDS(dat_nc,
            file = file_to_save)
    
    return(NULL)
  }
  
  return(NULL)
}
