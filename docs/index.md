# A Python and R blend for processing Sentinel-1 images, getting SAR-based vegetation indices, and sampling raster

[![DOI](https://zenodo.org/badge/522624694.svg)](https://zenodo.org/badge/latestdoi/522624694)

## Repository intro

The primary purpose of this repo is the need for a pipeline for downloading and preprocessing Sentinel-1 Ground Range Detected (GRD) images, computing Dual-polarization SAR vegetation indices, and sampling (with points coordinates) the processed scenes over a given Area of Interest (AOI). So, you are gonna find here both Spyder and RStudio (IDEs) projects, which means the repo is a blend of Python and R resources, and their scripts to do the above-mentioned steps.

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

![Pipeline_framework-Script_01](https://user-images.githubusercontent.com/52005057/185178301-6ff7cb73-33c0-4bd4-961a-5e7deeaad6b4.png)

### Script 02: reading and visualizing a single product band:

**WARNING**: From here and forward you will need a Python 3.4 or 3.6 environment, it is a SNAP project requirement. Check it out at:
1) **Getting Started with SNAP Toolbox in Python**: https://towardsdatascience.com/getting-started-with-snap-toolbox-in-python-89e33594fa04
2) **Install ESA SNAP ToolBox along with Current Updates and Snappy Python on UBUNTU 18.04 for Satellite Imagery Analysis**: https://kaustavmukherjee-66179.medium.com/install-esa-snap-toolbox-along-with-current-updates-and-snappy-python-on-ubuntu-18-04-696a5104e7f
3) **Configure Python to use the SNAP-Python (snappy) interface**: https://senbox.atlassian.net/wiki/spaces/SNAP/pages/50855941/Configure+Python+to+use+the+SNAP-Python+snappy+interface

![Pipeline_framework-Script_02](https://user-images.githubusercontent.com/52005057/185178373-92cd7128-bf52-4630-ba00-5d809e2d35a9.png)

### Script 03: preprocessing of Sentinel-1 SAR products (from removing thermal noise to orthorectification):

![Pipeline_framework-Script_03](https://user-images.githubusercontent.com/52005057/185178407-ed607a5d-44e9-4623-92c3-3ce314e617e3.png)

### Script 04: subsetting scenes using an polygon area of interest:

It is an optional script, and was designed to save disc space by subsetting scenes. Skip this step if you're not interested.

![Pipeline_framework-Script_04](https://user-images.githubusercontent.com/52005057/185178462-4566e0c6-6388-48b5-8b8f-27e31f3edba9.png)

### Script 05: computing SAR dual-pol vegetation indices:

For fast array computations, this script just read BEAM-DIMAP raster products using **snappy** and transform them to **NumPy** arrays, in order to compute the Dual-pol SAR vegetation indices. The indices are: **Cross-Ratio** (**CR**, Frison *et al.* (2018)), **Dual-polarization SAR vegetation index** (**DPSVI**, Periasamy (2018)), the **modified DPSVI** (**DPSVIm**, dos Santos *et al.* (2021)), the **normalized difference polarization index** (**Pol**, Hird *et al.* (2017)), and the **modified Radar Vegetation Index** (**RVIm**, Nasirzadehdizaji *et al.* (2019)).

![Pipeline_framework-Script_05](https://user-images.githubusercontent.com/52005057/189922775-6b82281b-3360-4760-81c3-2c9a1d21c5b2.png)

**References**

dos Santos, E. P., da Silva, D. D., & do Amaral, C. H. (2021). Vegetation cover monitoring in tropical regions using SAR-C dual-polarization index: seasonal and spatial influences. International Journal of Remote Sensing, 42(19), 7581–7609. https://doi.org/10.1080/01431161.2021.1959955

Bhogapurapu, N., Dey, S., Mandal, D., Bhattacharya, A., Karthikeyan, L., McNairn, H. and Rao, Y.S., 2022. Soil moisture retrieval over croplands using dual-pol L-band GRD SAR data. Remote Sensing of Environment, 271, p.112900. https://doi.org/10.1016/j.rse.2022.112900

Frison, P.-L., Fruneau, B., Kmiha, S., Soudani, K., Dufrêne, E., Toan, T. Le, Koleck, T., Villard, L., Mougin, E., & Rudant, J.-P. (2018). Potential of Sentinel-1 Data for Monitoring Temperate Mixed Forest Phenology. Remote Sensing, 10(12), 2049. https://doi.org/10.3390/rs10122049

Hird, J., DeLancey, E., McDermid, G., & Kariyeva, J. (2017). Google Earth Engine, Open-Access Satellite Data, and Machine Learning in Support of Large-Area Probabilistic Wetland Mapping. Remote Sensing, 9(12), 1315. https://doi.org/10.3390/rs9121315

Nasirzadehdizaji, R., Balik Sanli, F., Abdikan, S., Cakir, Z., Sekertekin, A., & Ustuner, M. (2019). Sensitivity Analysis of Multi-Temporal Sentinel-1 SAR Parameters to Crop Height and Canopy Coverage. Applied Sciences, 9(4), 655. https://doi.org/10.3390/app9040655

Periasamy, S. (2018). Significance of dual polarimetric synthetic aperture radar in biomass retrieval: An attempt on Sentinel-1. Remote Sensing of Environment, 217(September), 537–549. https://doi.org/10.1016/j.rse.2018.09.003

### Script 06: sampling raster products using R:

After processing raster products, use this script to sample raster bands either using coordinates of the points or the coordinates of the points and a set of buffers around them.

**WARNING**: it will works properly only using R version >= 4.2.1.

![Pipeline_framework-Script_06](https://user-images.githubusercontent.com/52005057/185178550-4ebabbf6-db22-42a4-bf11-cb85736eadbd.png)

## Final speech

This code is part of the Erli's Ph.D. thesis and its papers (author: Erli Pinto dos Santos).

Enjoy it, and feel free to contact me anytime.

By the way... contact me at: erlipinto@gmail.com or erli.santos@ufv.br
