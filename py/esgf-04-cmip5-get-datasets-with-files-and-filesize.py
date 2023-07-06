# get CORDEX datasets as txt, with file size (takes considerably longer than without)
# with progress print

from pyesgf.search import SearchConnection
import os

# set so no more warnings
os.environ["ESGF_PYCLIENT_NO_FACETS_STAR_WARNING"] = "zzz"

# cordex

fn = "data-raw/datasets-cmip5-with-files-and-size.txt"

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CMIP5", time_frequency="day", 
  experiment="historical,rcp26,rcp45,rcp85",
  variable="tas,tasmin,tasmax,pr",
  facets="ensemble,variable,model,realm", 
  latest=True, replica=False
  )

ds_all = ctx.search()

# check if file exists -> continue from end
n_lines = -1
if(os.path.exists(fn)):
  with open(fn, 'r') as file:
    n_lines = len(file.readlines())


f = open(fn, "a")
for i, ds in enumerate(ds_all):
  if(i < n_lines):
    continue
  print(str(i) + " of " + str(len(ds_all)))
  # get size in byte separately
  files = ds.file_context().search()
  for file in files:
    f.write(ds.dataset_id + "|" + file.filename + "|" + str(file.size) + "\n")
  
f.close()


