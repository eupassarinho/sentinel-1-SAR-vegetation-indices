# A Python and R blend for processing Sentinel-1 images, getting SAR-based vegetation indices, and sampling raster

[![DOI](https://zenodo.org/badge/522624694.svg)](https://zenodo.org/badge/latestdoi/522624694)

## Repository intro

The primary purpose of this repo is the need for a pipeline for downloading and preprocessing Sentinel-1 Ground Range Detected (GRD) images, computing Dual-polarization SAR vegetation indices, and sampling (with points coordinates) the processed scenes over a given Area of Interest (AOI). So, you are gonna find here both Spyder and RStudio (IDEs) projects, which means the repo is a blend of Python and R resources, and their scripts to do the above-mentioned steps.

### The repository, its Spyder and RStudio projects, and its codes were build upon the requirements:

1) To bring both Python and R capabilities of dealing with raster products. The radar products processing is feasible using Python resources, while raster sampling is faster using R resources.

2) It uses the packages: **asf_search** (Python 3.9), for downloading satellite products, main radar satellites, from the Alaska Satellite Facility; **snappy** (Python 3.6), the Python implementation of the SeNtinel Application Platform, from the European Space Agency (SNAP-ESA), which contains the Sentinel-1 Toolbox; and the **terra** package (R version 4.2.1), for dealing with raster and vectors fastest than other resources.

3) I tried not to personalize the pipeline, as you can personalize on your way and needs. This means that you are free to change it on your way, e.g., changing Sentinel-1 algorithms, methods, AOI, etc.

# Documentation
I strongly recommend you to check out what exactly you can do with this repository by checking the documentation at:
https://eupassarinho.github.io/sentinel-1-SAR-vegetation-indices/

# Citing it
I receive numerous requests to reproduce this work, and I'm happy to grant them all, I just ask you to attribute the original work to our repository.

## Citing the reference peer reviewed article:
![Article_Banner_MDPI_remotesensing-15-05464](https://github.com/eupassarinho/sentinel-1-SAR-vegetation-indices/assets/52005057/51fcd39b-0ac8-4317-946b-3892b5dad9c6)

Santos, Erli Pinto dos, Michel Castro Moreira, Elpídio Inácio Fernandes-Filho, José Alexandre M. Demattê, Emily Ane Dionizio, Demetrius David da Silva, Renata Ranielly Pedroza Cruz, Jean Michel Moura-Bueno, Uemeson José dos Santos, and Marcos Heil Costa. 2023. "Sentinel-1 Imagery Used for Estimation of Soil Organic Carbon by Dual-Polarization SAR Vegetation Indices" Remote Sensing 15, no. 23: 5464. https://doi.org/10.3390/rs15235464

## Check the reference via Zenodo:
https://doi.org/10.5281/zenodo.7339421

This code is part of the Erli's Ph.D. thesis and its papers. Enjoy it, and feel free to contact me anytime. You can contact me through: erlipinto@gmail.com or erli.santos@ufv.br
