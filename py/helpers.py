# helper functions

from pyesgf.search import SearchConnection
from pyesgf.logon import LogonManager
import os
import xarray as xr
from datetime import datetime # for info
# import tempfile
# import wget

# set so no more warnings
os.environ["ESGF_PYCLIENT_NO_FACETS_STAR_WARNING"] = "zzz"


def esgf_logon():
  # get password from file (no newline in txt file!)
  with open("py/myproxy_password.txt") as f:
    pw = f.readline()
  
  # login
  lm = LogonManager()
  lm.logoff()
  lm.logon(hostname='esgf-node.ipsl.upmc.fr', bootstrap=True, username="michaelmatiu", password=pw)
  return lm.is_logged_on()



def search_single(project="CORDEX", domain="EUR-11", time_frequency="day",
                  **kwargs):
  conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
  ctx = conn.new_context(
    project=project, domain=domain, time_frequency=time_frequency,
    **kwargs
    )
  ds_all = ctx.search(ignore_facet_check=True)
  if(len(ds_all) > 1):
    raise RuntimeWarning("Multiple datasets for: " + str(kwargs))
  return ds_all[0]




def crop_download(result, path, verbose=True, crop=[-11.0, 0.0, -8.0, -1.0]):
  
  xmin, xmax, ymin, ymax = crop
  files = result.file_context().search()
  od_urls = [f.opendap_url for f in files]

  for i, od_url in enumerate(od_urls):
    file_out = os.path.join(path, files[i].filename)
    if(os.path.exists(file_out)):
      continue
    
    try:
      ds = xr.open_dataset(od_url, chunks={'time': 120})
      ds = ds.sel(rlon=slice(xmin, xmax), rlat=slice(ymin, ymax))
      ds.to_netcdf(file_out)
      if verbose: 
        print(datetime.now().isoformat())
        print(file_out)
    except (KeyError, OSError, RuntimeError):
      print("Error: " + result.dataset_id)
      return False
  
  return True


