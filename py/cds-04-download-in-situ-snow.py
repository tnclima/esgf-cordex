import cdsapi
import os
import urllib3

urllib3.disable_warnings()

path_out = "/home/climatedata/stations/cds-landsurface-snow/"

client = cdsapi.Client()
dataset = "insitu-observations-surface-land"

# for y in reversed(range(1857, 2021)):
for y in range(1857, 2021):
  
  file_out = os.path.join(path_out, str(y) + ".zip")
  
  if not os.path.exists(file_out):
    
    request = {
        "time_aggregation": "daily",
        "variable": ["snow_depth"],
        "year": [str(y)],
        "usage_restrictions": [
            "non_commercial",
            "open"
        ],
        "data_quality": [
            "failed",
            "passed"
        ],
        "month": [
            "01", "02", "03",
            "04", "05", "06",
            "07", "08", "09",
            "10", "11", "12"
        ],
        "day": [
            "01", "02", "03",
            "04", "05", "06",
            "07", "08", "09",
            "10", "11", "12",
            "13", "14", "15",
            "16", "17", "18",
            "19", "20", "21",
            "22", "23", "24",
            "25", "26", "27",
            "28", "29", "30",
            "31"
        ]
    }
    try:
      client.retrieve(dataset, request, file_out)
    except Exception:
      pass



