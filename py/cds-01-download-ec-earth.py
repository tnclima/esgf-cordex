import cdsapi
import os
import urllib3

urllib3.disable_warnings()


c = cdsapi.Client()


path_out = "/home/climatedata/temp-cmip5/ec-earth/"
variables = ["tas", "tasmin", "tasmax", "pr"]
variables_cds = [
  '2m_temperature',
  'minimum_2m_temperature_in_the_last_24_hours',
  'maximum_2m_temperature_in_the_last_24_hours',
  'mean_precipitation_flux'
]

for i in range(4):
  
  i_path_out = os.path.join(path_out, variables[i])
  os.makedirs(i_path_out, exist_ok=True)
  i_file_out = os.path.join(i_path_out, variables[i] + "_ec-earth_historical.tar.gz")
  if not os.path.exists(i_file_out):
    # historical
    c.retrieve(
        'projections-cmip5-daily-single-levels',
        {
            'ensemble_member': 'r12i1p1',
            'format': 'tgz',
            'experiment': 'historical',
            'model': 'ec_earth',
            'variable': variables_cds[i],
            'period': [
                '18500101-18741231', '18750101-18991231', '19000101-19241231',
                '19250101-19491231', '19500101-19741231', '19750101-20121231',
            ],
        },
        i_file_out)
  
  # rcps
  all_rcps = ["rcp_2_6", "rcp_4_5", "rcp_8_5"]
  for i_rcp in all_rcps:
    
    i_file_out = os.path.join(i_path_out, variables[i] + "_ec-earth_" + i_rcp + ".tar.gz")
    if not os.path.exists(i_file_out):
      c.retrieve(
          'projections-cmip5-daily-single-levels',
          {
              'ensemble_member': 'r12i1p1',
              'format': 'tgz',
              'experiment': i_rcp,
              'model': 'ec_earth',
              'variable': variables_cds[i],
              'period': [
                  '20060101-20301231', '20310101-20551231', '20560101-21001231',
              ],
          },
          i_file_out)

