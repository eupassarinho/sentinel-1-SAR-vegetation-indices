# Repository intro

The primary purpose of this repo is the need for a pipeline for downloading and preprocessing Sentinel-1 Ground Range Detected (GRD) images, computing Dual-polarization SAR vegetation indices, and sampling (with points coordinates) the processed scenes over a given Area of Interest (AOI). So, you are gonna find here both Spyder and RStudio (IDEs) projects and their scripts to do the above-mentioned steps.

### The repository, its Spyder and RStudio projects, and its codes were build upon the requirements:
1) To bring both Python and R capabilities of dealing with raster products. The radar products processing is feasible using Python resources, while raster sampling is faster using R resources.

2) It uses the packages: **asf_search** (Python 3.9), for downloading satellite products, main radar satellites, from the Alaska Satellite Facility; **snappy** (Python 3.6), the Python implementation of the SeNtinel Application Platform, from the European Space Agency (SNAP-ESA), which contains the Sentinel-1 Toolbox; and the **terra** package (R version 4.2.1), for dealing with raster and vectors fastest than other resources.

3) I tried not to personalize the pipeline, as you can personalize on your way and needs. This means that you are free to change it on your way, e.g., changing Sentinel-1 algorithms, methods, AOI, etc.

4) I advise you to peek rapidly at the below-presented flowcharts, as they mean to summarize what the codes exactly do.

# How does it work and what does it do?
### Script 01: geographical search and batch download of SAR data in the Alaska Satellite Facility (ASF) dataset:

This code uses asf_search resources to do a geographical search within the ASF SAR data catalog, learn more about how its features work in:

1) **asf_search Basics**: https://docs.asf.alaska.edu/asf_search/basics/
2) **Bulk Download Sentinel 1 SAR Data**: https://medium.com/geekculture/bulk-download-sentinel-1-sar-data-d180ec0bfac1
3) (in Portuguese) **Download simultâneo de várias imagens de SAR (como Sentinel-1) via Python**: https://erlipinto.medium.com/download-simult%C3%A2neo-de-v%C3%A1rias-imagens-de-sar-como-sentinel-1-via-python-ba4c89011ccb

**WARNING**: to do bulk products download use a Python 3.9 environment. 

![Pipeline_framework-Script_01](https://user-images.githubusercontent.com/52005057/184925308-32fbb954-22cb-41f6-b392-1be074eca7ea.png)

### Script 02: reading and visualizing a single product band:

**WARNING**: From here and forward you will need a Python 3.4 or 3.6 environment, it is a SNAP project requirement. Check it out at:
1) **Getting Started with SNAP Toolbox in Python**: https://towardsdatascience.com/getting-started-with-snap-toolbox-in-python-89e33594fa04
2) **Install ESA SNAP ToolBox along with Current Updates and Snappy Python on UBUNTU 18.04 for Satellite Imagery Analysis**: https://kaustavmukherjee-66179.medium.com/install-esa-snap-toolbox-along-with-current-updates-and-snappy-python-on-ubuntu-18-04-696a5104e7f
3) **Configure Python to use the SNAP-Python (snappy) interface**: https://senbox.atlassian.net/wiki/spaces/SNAP/pages/50855941/Configure+Python+to+use+the+SNAP-Python+snappy+interface

![Pipeline_framework-Script_02](https://user-images.githubusercontent.com/52005057/184925460-77f836ca-bff0-4014-a025-773a57fc8862.png)

### Script 03: preprocessing of Sentinel-1 SAR products (from removing thermal noise to orthorectification):

![Pipeline_framework-Script_03](https://user-images.githubusercontent.com/52005057/184925506-2235258b-a2b9-4a51-b49d-b6f498e1a3ff.png)

### Script 04: subsetting scenes using an polygon area of interest:

It is an optional script, and was designed to save disc space by subsetting scenes. Skip this step if you're not interested.
![Pipeline_framework-Script_04](https://user-images.githubusercontent.com/52005057/184925536-4fae038a-588d-4687-94d8-65882407b7f8.png)

### Script 05: computing SAR dual-pol vegetation indices:

![Pipeline_framework-Script_05](https://user-images.githubusercontent.com/52005057/184925769-8e3fc9c6-15b4-42bb-8bb8-65cb669a2b34.png)

### Script 06: sampling raster products using R:

After processing raster products, use this script to sample raster bands either using coordinates of the points or the coordinates of the points and a set of buffers around them.

**WARNING**: it will works properly only using R version >= 4.2.1.

![Pipeline_framework-Script_06](https://user-images.githubusercontent.com/52005057/184925805-9008c05e-25a5-462c-945d-51c30c3fc5ec.png)

Enjoy it, and feel free to contact me anytime.
