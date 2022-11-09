# download missing models and crop to GAR

path_out = "/home/climatedata/eurocordex/"

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
data_todo1 = pd.read_csv("data-raw/redownload-errors-01-raw.csv")
data_todo1.drop("institute_rcm", axis=1, inplace=True)
data_todo1.rename(columns={"gcm": "driving_model"}, inplace=True)

for i in range(len(data_todo1)):
  ds = search_single(project="CORDEX", **data_todo1.iloc[i].to_dict())
  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  crop_download(ds, ds_path)



data_todo2 = pd.read_csv("data-raw/redownload-errors-02-adj.csv")
data_todo2.drop("institute_rcm", axis=1, inplace=True)
data_todo2.rename(columns={"gcm": "driving_model"}, inplace=True)
data_todo2.rename(columns={"rcm_version": "bias_adjustment"}, inplace=True)

for i in range(len(data_todo2)):
  ds = search_single(project="CORDEX-Adjust", **data_todo2.iloc[i].to_dict())
  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  crop_download(ds, ds_path)









