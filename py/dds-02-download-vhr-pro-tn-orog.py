import ddsapi
import os

c = ddsapi.Client()

path_out = "/home/climatedata/temp-cmcc-dds/vhr-pro/"

    
file_out = os.path.join(path_out, "orog_cmcc2km_tn.nc")

c.retrieve("climate-projections-rcp85-downscaled-over-italy", "const",
  {
      "area": {
          "north": 46.7,
          "south": 45.3,
          "east": 12.5,
          "west": 10
      },
      "variable": "surface_altitude",
      "format": "netcdf"
  },
  file_out)



