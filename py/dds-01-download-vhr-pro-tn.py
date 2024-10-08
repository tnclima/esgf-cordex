import ddsapi
import os

c = ddsapi.Client()

path_out = "/home/climatedata/temp-cmcc-dds/vhr-pro/"

# variables = ["rsds", "tas", "snw", "vas", "uas", "huss", "pr"]
# variables_dds = [
#     "surface_net_downward_shortwave_flux",
#     "air_temperature",
#     "lwe_thickness_of_surface_snow_amount",
#     "grid_northward_wind",
#     "grid_eastward_wind",
#     "specific_humidity",
#     "precipitation_amount"
# ]

variables = ["tdew", "psl"]
variables_dds = [
    "dew_point_temperature",
    "air_pressure_at_sea_level"
]


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
                                variables[i] + "_" + i_rcp + "_" + str(i_year) + "_cmcc2km_tn.nc")
      c.retrieve("climate-projections-rcp85-downscaled-over-italy", i_rcp,
        {
            "area": {
                "north": 46.7,
                "south": 45.3,
                "east": 12.5,
                "west": 10
            },
            "time": {
                "year": i_year
            },
            "variable": variables_dds[i],
            "format": "netcdf"
        },
        i_file_out)




