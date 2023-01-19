# download missing models and crop to GAR

path_out = "/home/climatedata/eurocordex2-other/"

# modules
import os
import pandas as pd

# import other functions
import sys
sys.path.append("py")
from helpers import search_single, crop_download, esgf_logon
# login
esgf_logon()


# orog
data_todo_orog = pd.read_csv("data-raw/to-download3_orog.csv")
# some have r0i0p0 some don't, run with and without the next line commented out
data_todo_orog.drop("ensemble", axis=1, inplace=True)

# remo2009 fix
crop = [-11, 0, -8, -1] # default
crop = [x + 0.055 for x in crop]

for i in range(len(data_todo_orog)):
  try:
    ds = search_single(time_frequency="fx", variable="orog", **data_todo_orog.iloc[i].to_dict())
    ds_info = ds.dataset_id.split(".")
    ds_var = ds_info[10]
    ds_path = os.path.join(path_out, ds_var)
    os.makedirs(ds_path, exist_ok=True)
    ds_rcm = ds_info[7]
    if ds_rcm != "REMO2009":
      crop_download(ds, ds_path)
    else:
      crop_download(ds, ds_path, crop=crop)
  except:
    pass
  





