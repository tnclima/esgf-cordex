import ddsapi
import os

c = ddsapi.Client()

path_out = "/home/climatedata/temp-cmcc-dds/cosmo8km/"

variables = ["tasmax", "tasmin", "tas", "pr"]
variables_cds = [
  "max_air_temperature",
  "min_air_temperature",
  "air_temperature",
  "total_precipitation"
]


for i in range(4):

  # historical
  i_file_out = os.path.join(path_out, variables[i] + "_historical_TN.nc")    
  c.retrieve("climate-projections-8km-over-italy", "historical",
    {
        "area": {
            "north": 46.7,
            "south": 45.3,
            "east": 12.5,
            "west": 10
        },
        "variable": variables_cds[i],
        "format": "netcdf"
    },
    i_file_out)

  # rcps
  all_rcps = ["rcp45", "rcp85"]
  for i_rcp in all_rcps:
    
    i_file_out = os.path.join(path_out, variables[i] + "_" + i_rcp + "_TN.nc")
    c.retrieve("climate-projections-8km-over-italy", i_rcp,
      {
          "area": {
              "north": 46.7,
              "south": 45.3,
              "east": 12.5,
              "west": 10
          },
          "variable": variables_cds[i],
          "format": "netcdf"
      },
      i_file_out)




