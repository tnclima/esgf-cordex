# download missing models and crop to GAR

path_out = "/home/climatedata/eurocordex-temp/orog/"

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
data_todo1 = pd.read_csv("data-raw/to-download3_orog.csv")

# some have r0i0p0 some don't, run with and without the next line commented out
data_todo1.drop("ensemble", axis=1, inplace=True)


for i in range(len(data_todo1)):
  
  file_wget = "wget_" + "_".join(data_todo1.iloc[i].to_list()) + ".sh"
  file_wget_path = os.path.join(path_out, file_wget)
  
  if(not os.path.exists(file_wget_path)):
  
    try:
      ds = search_single(time_frequency="fx", variable="orog", **data_todo1.iloc[i].to_dict())
    except (RuntimeError, RuntimeWarning, IndexError):
      continue
   
    fc = ds.file_context()
    wget_script_content = fc.get_download_script()
    
    with open(file_wget_path, "w") as f:
      f.write(wget_script_content)


