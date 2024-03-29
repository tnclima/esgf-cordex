# get CORDEX datasets as txt

from pyesgf.search import SearchConnection

# adjust daily

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CORDEX-Adjust", domain="EUR-11", time_frequency="day", facets="ensemble", latest=True,
  )

ds_all = ctx.search()

f = open("data-raw/datasets-cordex-adjust.txt", "w")
for ds in ds_all:
  f.write(ds.dataset_id + "\n")
f.close()


# cordex daily

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CORDEX", domain="EUR-11", time_frequency="day", facets="ensemble", latest=True,
  )

ds_all = ctx.search()

f = open("data-raw/datasets-cordex.txt", "w")
for ds in ds_all:
  f.write(ds.dataset_id + "\n")
f.close()


# cordex fx

conn = SearchConnection('http://esgf-node.ipsl.upmc.fr/esg-search', distrib=True)
ctx = conn.new_context(
  project="CORDEX", domain="EUR-11", time_frequency="fx", facets="ensemble", latest=True,
  )

ds_all = ctx.search()

f = open("data-raw/datasets-cordex-fx.txt", "w")
for ds in ds_all:
  f.write(ds.dataset_id + "\n")
f.close()

