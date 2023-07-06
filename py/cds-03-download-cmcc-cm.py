import cdsapi
import os
import urllib3

urllib3.disable_warnings()

c = cdsapi.Client()


path_out = "/home/climatedata/temp-cmip5/cmcc-cm/"
variables = ["tas", "tasmin", "tasmax", "pr"]
variables_cds = [
  '2m_temperature',
  'minimum_2m_temperature_in_the_last_24_hours',
  'maximum_2m_temperature_in_the_last_24_hours',
  'mean_precipitation_flux'
]

#note: no precip for rcp85 scenario on cds! -> wget from esgf

for i in range(4):
  
  i_path_out = os.path.join(path_out, variables[i])
  os.makedirs(i_path_out, exist_ok=True)
    
  for y in range(1850, 2006):
    per = str(y) + "0101-" + str(y) + "1231"
    i_file_out = os.path.join(i_path_out, variables[i] + "_cmcc_historical_" + per + ".tar.gz")
    if not os.path.exists(i_file_out):
    
      # historical
      c.retrieve(
          'projections-cmip5-daily-single-levels',
          {
              'ensemble_member': 'r1i1p1',
              'format': 'tgz',
              'experiment': 'historical',
              'model': 'cmcc_cm',
              'variable': variables_cds[i],
              'period': per,
          },
          i_file_out)
    
  
  # rcps
  # all_rcps = ["rcp_2_6", "rcp_4_5", "rcp_8_5"]
  all_rcps = ["rcp_4_5", "rcp_8_5"]
  for i_rcp in all_rcps:
    
      for y in range(2006, 2101):
        per = str(y) + "0101-" + str(y) + "1231"
        i_file_out = os.path.join(i_path_out, variables[i] + "_cmcc_" + i_rcp + "_" + per + ".tar.gz")
        if not os.path.exists(i_file_out):
          c.retrieve(
              'projections-cmip5-daily-single-levels',
              {
                  'ensemble_member': 'r1i1p1',
                  'format': 'tgz',
                  'experiment': i_rcp,
                  'model': 'cmcc_cm',
                  'variable': variables_cds[i],
                  'period': per,
              },
              i_file_out)

