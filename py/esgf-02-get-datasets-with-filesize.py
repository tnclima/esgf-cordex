# get CORDEX datasets as txt, with file size (takes considerably longer than without)
# with progress print

from pyesgf.search import SearchConnection
import os

# set so no more warnings
os.environ["ESGF_PYCLIENT_NO_FACETS_STAR_WARNING"] = "zzz"

# adjust

# conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
# ctx = conn.new_context(
#   project="CORDEX-Adjust", domain="EUR-11", time_frequency="day", facets="ensemble,output"
#   )
# 
# ds_all = ctx.search()
# 
# f = open("data-raw/datasets-cordex-adjust-with-size.txt", "w")
# for i, ds in enumerate(ds_all):
#   print(str(i) + " of " + str(len(ds_all)))
#   # get size in byte separately
#   files = ds.file_context().search()
#   total_file_size = sum([f.size for f in files])
#   
#   f.write(ds.dataset_id + "|" + str(total_file_size) + "\n")
# f.close()


# cordex

fn = "data-raw/datasets-cordex-with-size.txt"

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CORDEX", domain="EUR-11", time_frequency="day", 
  variable="tas,tasmin,tasmax,hurs,rsds,rlds,uas,vas,pr,ps",
  facets="ensemble,variable"
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
  total_file_size = sum([f.size for f in files])
  
  f.write(ds.dataset_id + "|" + str(total_file_size) + "\n")
f.close()


