# -*- coding: utf-8 -*-
"""

Code wroten to read and view Sentinel-1 products.

Created on Mon Jul 18, 2022
Last updated on: Wed July 20, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% REQUESTED MODULES

# For listing files within a directory matching name patterns:
import glob
# Fast arrays computation (better to visualize):
import numpy as np
# For data viz
import matplotlib.pyplot as plt
# snappy module to import and export SNAP file formats:
from snappy import ProductIO

#%% READING MULTIPLE PRODUCTS ('.zip') WITH GLOB LOOPING

# Path where Sentinel-1 just got ('.zip') were located:
path = r'I:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\GRD_Level_1'

# Only Ground Range Detected images:
product_type = 'GRD'

files = glob.glob(path + '**/*.zip')

files = list(filter(lambda k: product_type in k, files))

# Printing all found files:
print(files)

#%% READING SENTINEL PRODUCT AND GETTING INFOS:

product = ProductIO.readProduct(str(files[0]))

# Getting band names:
list(product.getBandNames())

#%% DEFINING FUNCTION TO PLOT BAND

# Function to visualize bands from products:
def plotBand(product, band, vmin, vmax):
    band = product.getBand(band)
    w = band.getRasterWidth()
    h = band.getRasterHeight()
    print(w, h)
    band_data = np.zeros(w * h, np.float32)
    band.readPixels(0, 0, w, h, band_data)
    band_data.shape = h, w
    width = 12
    height = 12
    plt.figure(figsize=(width, height))
    imgplot = plt.imshow(band_data, cmap = "gray", vmin=vmin, vmax=vmax)
    return imgplot

#%% VISUALIZING BAND:
    
plotBand(product, 'Amplitude_VH', 0, 10)