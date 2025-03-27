import ddsapi
import os

c = ddsapi.Client()

path_out = "/home/climatedata/temp-cmcc-dds/vhr-pro-tnaa/"

variables = ["pr", "tas", "rsds", "snw", "vas", "uas", "huss", "tdew", "psl"]
variables_dds = [
    "precipitation_amount",
    "air_temperature",
    "surface_net_downward_shortwave_flux",
    "lwe_thickness_of_surface_snow_amount",
    "grid_northward_wind",
    "grid_eastward_wind",
    "specific_humidity",
    "dew_point_temperature",
    "air_pressure_at_sea_level"
]
# 
# variables = ["tdew", "psl"]
# variables_dds = [
#     "dew_point_temperature",
#     "air_pressure_at_sea_level"
# ]
# 

for i in range(len(variables)):

  # rcps
  all_rcps = ["historical", "rcp45", "rcp85"]
  for i_rcp in all_rcps:
    
    if i_rcp == "historical":
      all_years = range(1981, 2006)
    else:
      all_years = range(2006, 2071)
      
    for i_year in all_years:
    
      os.makedirs(os.path.join(path_out, variables[i]), exist_ok=True)
      i_file_out = os.path.join(path_out, 
                                variables[i],
                                variables[i] + "_" + i_rcp + "_" + str(i_year) + ".nc")
                                
      if not os.path.exists(i_file_out):
        c.retrieve("climate-projections-rcp85-downscaled-over-italy", i_rcp,
          {
              "area": {
                  "north": 47.3,
                  "south": 45.3,
                  "east": 12.8,
                  "west": 10
              },
              "time": {
                  "year": i_year
              },
              "variable": variables_dds[i],
              "format": "netcdf"
          },
          i_file_out)




