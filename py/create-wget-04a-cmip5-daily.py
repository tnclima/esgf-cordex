# run wget scripts manually later

path_out = "/home/climatedata/temp-cmip5/wget-daily/"
variables = ["tas", "tasmin", "tasmax", "pr"]

from pyesgf.search import SearchConnection
import os
import re

# set so no more warnings
os.environ["ESGF_PYCLIENT_NO_FACETS_STAR_WARNING"] = "zzz"

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CMIP5", time_frequency="day", 
  experiment="historical,rcp26,rcp45,rcp85",
  variable="tas,tasmin,tasmax,pr", realm="atmos",
  facets="ensemble,variable,model", 
  latest=True, replica=False
  )

ds_all = ctx.search(ignore_facet_check=True)


for i, ds in enumerate(ds_all):
  
  file_wget = "wget_" + ds.dataset_id.split("|")[0] + ".sh"
  fc = ds.file_context()
  wget_script_content = fc.get_download_script()
  wget_script_lines = wget_script_content.split("\n")
  
  # reg = re.compile(r'(tas|tasmin|tasmax|pr)_day_') # all variables
  # wget_subset = [x for x in wget_script_lines if not "_day_" in x or reg.search(x)]
  
  for v in variables:
    wget_subset = [x for x in wget_script_lines if 
      not "_day_" in x or v + "_day_" in x]
      
    file_wget_path = os.path.join(path_out, v, file_wget)
    os.makedirs(os.path.join(path_out, v), exist_ok=True)

    with open(file_wget_path, "w") as f:
      f.write("\n".join(wget_subset))








