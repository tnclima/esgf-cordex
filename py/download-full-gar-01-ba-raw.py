# download example rcp85 (same as hist) cropped to GAR

path_out = "/media/mitch/usb 160GB/cordex-data/"
file_already_downloaded = "/media/mitch/usb 160GB/cordex-downloaded.txt"


# modules
from pyesgf.search import SearchConnection
from pyesgf.logon import LogonManager
import os
import xarray as xr
import matplotlib.pyplot as plt
from datetime import datetime # for info
# set so no more warnings
os.environ["ESGF_PYCLIENT_NO_FACETS_STAR_WARNING"] = "zzz"

# get password from file (no newline in txt file!)
with open("py/myproxy_password.txt") as f:
  pw = f.readline()

#  print(datetime.now().isoformat())


# login
lm = LogonManager()
lm.logoff()
lm.logon(hostname='esgf-node.ipsl.upmc.fr', bootstrap=True, username="michaelmatiu", password=pw)
lm.is_logged_on()


# search adjust
conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CORDEX-Adjust", domain="EUR-11", time_frequency="day",
  variable="prAdjust,tasmaxAdjust,tasminAdjust,tasAdjust")
ds_all = ctx.search()


# function to loop over a dataset
def crop_download(result, path, verbose=True):
  
  files = result.file_context().search()
  od_urls = [f.opendap_url for f in files]

  for i, od_url in enumerate(od_urls):
    file_out = os.path.join(path, files[i].filename)
    if(os.path.exists(file_out)):
      continue
    ds = xr.open_dataset(od_url, chunks={'time': 120})
    ds = ds.sel(rlat=slice(-8, -1), rlon=slice(-11, 0))
    ds.to_netcdf(file_out)
    if verbose: 
      print(datetime.now().isoformat())
      print(file_out)

def add_id_downloaded(filename, dataset_id):
  with open(filename, "a") as f:
      f.write(dataset_id + "\n")


# get already downlaoded files:
if os.path.exists(file_already_downloaded):
  with open(file_already_downloaded) as f:
    id_downloaded = f.read().splitlines()
else:
  id_downloaded = []


# loop over all datasets
for i, ds in enumerate(ds_all):

  ds_info = ds.dataset_id.split(".")
  ds_var = ds_info[10]
  if not ds.dataset_id in id_downloaded:
    ds_path = os.path.join(path_out, ds_var)
    os.makedirs(ds_path, exist_ok=True)
    crop_download(ds, ds_path)
    add_id_downloaded(file_already_downloaded, ds.dataset_id)
  
  # also download the same RCM without bias adjustment (same rcp)
  i_ctx = conn.new_context(
      project="CORDEX", domain="EUR-11", time_frequency="day",
      driving_model=ds_info[4], experiment=ds_info[5],
      ensemble=ds_info[6], rcm_name=ds_info[7], variable=ds_var.replace("Adjust", ""), 
      )
  ds_no_ba = i_ctx.search()
  if(len(ds_no_ba) > 1):
    raise RuntimeWarning("Multiple datasets for: " + str(ds_info))
  ds2 = ds_no_ba[0]
  
  if not ds2.dataset_id in id_downloaded:
    ds2_info = ds2.dataset_id.split(".")
    ds2_var = ds2_info[10]
    ds2_path = os.path.join(path_out, ds2_var)
    os.makedirs(ds2_path, exist_ok=True)
    crop_download(ds2, ds2_path)
    add_id_downloaded(file_already_downloaded, ds2.dataset_id)
  
  # also download the same RCM without bias adjustment (historical)
  i_ctx = conn.new_context(
      project="CORDEX", domain="EUR-11", time_frequency="day",
      driving_model=ds_info[4], experiment="historical",
      ensemble=ds_info[6], rcm_name=ds_info[7], variable=ds_var.replace("Adjust", ""), 
      )
  ds_no_ba = i_ctx.search()
  if(len(ds_no_ba) > 1):
    raise RuntimeWarning("Multiple datasets for: " + str(ds_info))
  ds2 = ds_no_ba[0]
  
  if not ds2.dataset_id in id_downloaded:
    ds2_info = ds2.dataset_id.split(".")
    ds2_var = ds2_info[10]
    ds2_path = os.path.join(path_out, ds2_var)
    os.makedirs(ds2_path, exist_ok=True)
    crop_download(ds2, ds2_path)
    add_id_downloaded(file_already_downloaded, ds2.dataset_id)



  







