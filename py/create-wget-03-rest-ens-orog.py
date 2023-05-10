# run wget scripts manually later

path_out = "/home/climatedata/temp-eur11/wget/"

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
data_todo1 = pd.read_csv("data-raw/to-download2-rest-ensemble-orog.csv")
data_todo1.drop("institute_rcm", axis=1, inplace=True)
data_todo1.rename(columns={"gcm": "driving_model"}, inplace=True)
data_todo1.rename(columns={"downscale_realisation": "rcm_version"}, inplace=True)

for i in range(len(data_todo1)):
  ds_var = data_todo1.iloc[i]["variable"]
  ds_path = os.path.join(path_out, ds_var)
  os.makedirs(ds_path, exist_ok=True)
  file_wget = "wget_" + "_".join(data_todo1.iloc[i].to_list()) + ".sh"
  file_wget_path = os.path.join(ds_path, file_wget)
  
  if not os.path.exists(file_wget_path):
    ds = search_single(project="CORDEX", time_frequency="fx", **data_todo1.iloc[i].to_dict())
    fc = ds.file_context()
    wget_script_content = fc.get_download_script()

    with open(file_wget_path, "w") as f:
      f.write(wget_script_content)










