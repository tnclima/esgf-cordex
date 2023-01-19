# download remo again because of grid issues

# run wget scripts manually later

# instead of cropping, better use cdo remapcon,target.nc in.nc out.nc
# to solve gridcell corner/center issues


path_out = "/home/climatedata/eurocordex-temp/"

# modules
import os
import pandas as pd

# import other functions
import sys
sys.path.append("py")
from helpers import search_single, crop_download, esgf_logon
# login
esgf_logon()


# read and proc to download
data_todo1 = pd.read_csv("data-raw/to-download5-remo2.csv")
data_todo1.drop("institute_rcm", axis=1, inplace=True)
data_todo1.rename(columns={"gcm": "driving_model"}, inplace=True)

for i in range(len(data_todo1)):
  ds = search_single(project="CORDEX", **data_todo1.iloc[i].to_dict())
  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  
  file_wget = "wget_" + "_".join(data_todo1.iloc[i].to_list()) + ".sh"
  file_wget_path = os.path.join(ds_path, file_wget)
  fc = ds.file_context()
  wget_script_content = fc.get_download_script()
  
  with open(file_wget_path, "w") as f:
    f.write(wget_script_content)



data_todo2 = pd.read_csv("data-raw/to-download5-remo1.csv")
data_todo2.drop("institute_rcm", axis=1, inplace=True)
data_todo2.rename(columns={"gcm": "driving_model"}, inplace=True)
data_todo2.rename(columns={"rcm_version": "bias_adjustment"}, inplace=True)

for i in range(len(data_todo2)):
  ds = search_single(project="CORDEX-Adjust", **data_todo2.iloc[i].to_dict())
  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  
  file_wget = "wget_" + "_".join(data_todo2.iloc[i].to_list()) + ".sh"
  file_wget_path = os.path.join(ds_path, file_wget)
  fc = ds.file_context()
  wget_script_content = fc.get_download_script()
  
  with open(file_wget_path, "w") as f:
    f.write(wget_script_content)









