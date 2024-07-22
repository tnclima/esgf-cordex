import ddsapi
import os

c = ddsapi.Client()

path_out = "/home/climatedata/temp-vhr-pro/"
i_file_out = os.path.join(path_out, "test2.nc")

c.retrieve("climate-projections-rcp85-downscaled-over-italy", "historical",
{
    "area": {
        "north": 46.7,
        "south": 45.3,
        "east": 12.5,
        "west": 10
    },
    "time": {
        "hour": [
            "00",
            "01",
            "02",
            "03",
            "04",
            "05",
            "06",
            "07",
            "08",
            "09",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23"
        ],
        "year": [
            "1981"
        ],
        "month": [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12"
        ],
        "day": [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23",
            "24",
            "25",
            "26",
            "27",
            "28",
            "29",
            "30",
            "31"
        ]
    },
    "variable": [
        "surface_net_downward_shortwave_flux",
        "air_temperature",
        "lwe_thickness_of_surface_snow_amount",
        "grid_northward_wind",
        "grid_eastward_wind",
        "specific_humidity",
        "precipitation_amount"
    ],
    "format": "netcdf"
},
i_file_out)
