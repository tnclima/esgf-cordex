# get timeseries for maria grazia

library(eurocordexr)
library(foreach)
library(fs)

path_out <- "data-extract/mg/"
path_out_export <- "data-extract/mg-export/"

dat_inv <- get_inventory("/home/climatedata/eurocordex/", add_files = T)

dat_glacier <- fread("data-raw/maria_grazia_area_glacierinterest.csv")
lon <- mean(dat_glacier$X_wgs84_EPSG4326)
lat <- mean(dat_glacier$Y_wgs84_EPSG4326)


dat_extract <- data.table(stn = c("GlacierMariaGrazia", "GlacierMariaGrazia_south"),
                          lon = c(lon, lon),
                          lat = c(lat, lat-0.11))

# delete corrupt files ----------------------------------------------------

# dat_inv[249, list_files][[1]][2] %>% file.remove()

# check vertices ----------------------------------------------------------

file_rcm <- "/home/climatedata/eurocordex/tas/tas_EUR-11_CNRM-CERFACS-CNRM-CM5_historical_r1i1p1_CLMcom-CCLM4-8-17_v1_day_19500101-19501231.nc"

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
  
  grid_lon_vert <- ncvar_get(ncobj, "lon_vertices")
  grid_lat_vert <- ncvar_get(ncobj, "lat_vertices")
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



# extract all -------------------------------------------------------------

mitmatmisc::init_parallel_ubuntu(8)

# extract data and save files

foreach(
  i_stn = dat_extract$stn,
  i_lon = dat_extract$lon,
  i_lat = dat_extract$lat
) %do% {
  
  foreach(i_nc = 1:nrow(dat_inv), .inorder = F) %dopar% {
    
    # create filename
    dat_inv[i_nc, paste0(# variable, "_",
      gcm, "_",
      institute_rcm, "_",
      experiment, "_",
      ensemble, "_",
      downscale_realisation, ".rds")] %>% 
      # pre-append path
      file.path(path_out, 
                i_stn, 
                dat_inv[i_nc, variable], 
                .) -> file_to_save
    
    # create directory and skip if file already exists
    if(!dir.exists(dirname(file_to_save))) dir.create(dirname(file_to_save), recursive = T)
    if(file.exists(file_to_save)) return(NULL)
    
    # subloop to extract all data for a specific inventory row
    dat_nc <- foreach(
      fn = dat_inv[i_nc, unlist(list_files)],
      .final = rbindlist
    ) %do% {
      
      dat <- rotpole_nc_point_to_dt(filename = fn,
                                    variable = dat_inv[i_nc, variable],
                                    point_lon = i_lon,
                                    point_lat = i_lat,
                                    interpolate_to_standard_calendar = T,
                                    verbose = F)
      
      dat
      
      
    }
    
    saveRDS(dat_nc,
            file = file_to_save)
    
    return(NULL)
  }
  
  return(NULL)
}

