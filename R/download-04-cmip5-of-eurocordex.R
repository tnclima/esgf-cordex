# overview of data

library(eurocordexr)
setDTthreads(4)
library(fs)
library(stringr)

dat_cmip5 <- fread("data-raw/datasets-cmip5-with-files-and-size.txt",
              col.names = c("dataset_id", "esgf_node", "filename", "size_byte"))
dat_cmip5[, c("variable", "time_frequency", "gcm", "experiment", "ensemble", "period") := 
            tstrsplit(stringr::str_sub(filename, end = -4), "[_]")]
dat_cmip5[, size_GB := size_byte/1024/1024/1024]
dat_cmip5[, c("date_start", "date_end") := tstrsplit(period, "-")]

dat_cmip5_sum <- dat_cmip5[, 
                           .(date_start = min(date_start),
                             date_end = max(date_end),
                             size_GB = sum(size_GB)),
                           .(variable, time_frequency, gcm, experiment, ensemble)]

dat_inv <- get_inventory("/home/climatedata/eurocordex2-rest/merged/")



# subset cmip5 to eurocordex ----------------------------------------------

dat_inv[variable == "pr", .N, .(gcm = shortnames_gcm[gcm], experiment, ensemble)]
dat_inv[variable == "pr"] %>% with(table(shortnames_rcm[institute_rcm], shortnames_gcm[gcm]))
dat_inv[variable == "pr" & gcm == "ICHEC-EC-EARTH"] %>% with(table(institute_rcm, ensemble))
dat_inv[variable == "pr" & gcm == "MPI-M-MPI-ESM-LR"] %>% with(table(institute_rcm, ensemble))

dat_inv_gcm <- dat_inv[, .(gcm = shortnames_gcm[gcm], experiment, ensemble)] %>% unique


dat_cmip5_subset <- dat_cmip5_sum[variable %in% c("tas", "tasmin", "tasmax", "pr")] %>% 
  merge(dat_inv_gcm) %>% 
  .[gcm != "EC-EARTH"] %>% # get ec-earth from cds, since r12 not on esgf
  # .[!(gcm == "EC-EARTH" & ensemble != "r12i1p1")] %>% # remove multiple ec-earth ensemble
  .[!(gcm == "MPI-ESM-LR" & ensemble != "r1i1p1")] # remove multiple mpi ensemble
  


# get ec-earth from CDS


# copy rest of scripts (already produces in other function)
dat_loop <- dat_cmip5_subset %>% dcast(... ~ variable)

for(i_var in c("tas", "tasmin", "tasmax", "pr")){
  
  path_in <- path("/home/climatedata/temp-cmip5/wget-daily/", i_var)
  path_out <- path("/home/climatedata/temp-cmip5/eurocordex-gcm/", i_var)
  
  dir_create(path_out)
  
  files_in <- dir_ls(path_in)
  
  for(i in 1:nrow(dat_loop)){
    
    files_in %>% 
      str_subset(dat_loop[i, gcm]) %>% 
      str_subset(dat_loop[i, experiment]) %>% 
      str_subset(dat_loop[i, ensemble]) -> file_to_copy
    
    if(length(file_to_copy) != 1) stop("check length of file_to_copy")
    
    file_copy(file_to_copy,
              path(path_out, path_file(file_to_copy)))
    
  }
}



# remove post 2100 from files ---------------------------------------------

# too complex, since each gcm different splitting
# 
# for(i_var in c("tas", "tasmin", "tasmax", "pr")){
#   
#   path_in <- path("/home/climatedata/temp-cmip5/eurocordex-gcm/", i_var)
#   
#   files_in <- dir_ls(path_in)
#   
#   for(i_file in files_in){
#     
#     fc <- readLines(i_file)
#     i_nc_files <- which(str_starts(fc, str_c("^.", i_var)))
#     i_nc_files_chr <- fc[i_nc_files]
#     i_2100 <- str_detect(i_nc_files_chr, "_21[0-9]{2}")
#     
#     if(any(i_2100)){
#       i_nc_files_chr[i_2100]
#     }
# 
#     
#   }
# }




