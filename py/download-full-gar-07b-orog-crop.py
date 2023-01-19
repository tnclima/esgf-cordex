# crop orog from wget

# delete manually the non-cropped files afterwards!!

path_in = "/home/climatedata/eurocordex-temp/orog/"
path_out = "/home/climatedata/eurocordex-temp2/orog/"

import os
from glob import glob
import xarray as xr
from datetime import datetime # for info

all_files = glob(os.path.join(path_in, "*.nc"))
  
for file_in in all_files:
  file_out = os.path.join(path_out, os.path.basename(file_in))
  if(not os.path.exists(file_out)):
    ds = xr.open_dataset(file_in, chunks={'time': 120})
    
    ds_info = os.path.basename(file_in).split("_")
    ds_rcm = ds_info[5]
    if ds_rcm != "MPI-CSC-REMO2009":
      ds = ds.sel(rlat=slice(-8, -1), rlon=slice(-11, 0))
    else:
      # same indices, same as cdo setgrid
      # ds = ds.sel(rlat=slice(-8 + 0.055, -1 + 0.055), rlon=slice(-11 - 0.055, 0 - 0.055)) 
      # better! use cdo remapcon,target in out 
    
    ds.to_netcdf(file_out)
    print(datetime.now().isoformat())
    print(file_out)



