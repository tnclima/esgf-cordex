# download missing models and crop to GAR

path_out = "/home/climatedata/eurocordex2-rest/"

# modules
import os
import pandas as pd

# import other functions
import sys
sys.path.append("py")
from helpers import search_single, crop_download, esgf_logon
# login
esgf_logon()


# read in
data_todo_ens = pd.read_csv("data-raw/to-download2-rest-ensemble.csv")
data_todo_ens.drop("institute_rcm", axis=1, inplace=True)
data_todo_ens.rename(columns={"gcm": "driving_model"}, inplace=True)
data_todo_ens.rename(columns={"downscale_realisation": "rcm_version"}, inplace=True)

for i in range(len(data_todo_ens)):
  ds = search_single(**data_todo_ens.iloc[i].to_dict())
  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  crop_download(ds, ds_path)
  





