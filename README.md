# esgf-cordex

Manage login and download from ESGF servers.

- lookup content with filesizes
- download with serverside cropping
- batch generate wget script
- extract single point time series


## Setup

Create conda environment with the needed packages (esgf-pyclient, xarray, ...)

```
conda env create -f environment.yml
```

To use the myproxylogin facility, you need to save your myproxy password in the file `py/myproxy_password.txt` with no newline at the end. And adjust username in the respective scripts...

