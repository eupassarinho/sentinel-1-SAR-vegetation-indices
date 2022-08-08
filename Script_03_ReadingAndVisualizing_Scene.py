# -*- coding: utf-8 -*-
"""

Code wroten to read and view Sentinel-1 products.

Created on Mon Jul 18, 2022
Last updated on: Wed July 20, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

from snappy import ProductIO
import numpy as np
import matplotlib.pyplot as plt
import glob 

path_to_product = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed\S1A_IW_GRDH_1SDV_20170706T083547_20170706T083612_017348_01CF83_B8D5_Orb_NR_Brd_Cal_Spk_TF_TC_10m.tif'

product = ProductIO.readProduct(path_to_product)

list(product.getBandNames())

amplitude_vh = product.getBand('Amplitude_VH')

w = amplitude_vh.getRasterWidth()
h = amplitude_vh.getRasterHeight()

Amplitude_VH_data = np.zeros(w * h, np.float64)
amplitude_vh.readPixels(0, 0, w, h, Amplitude_VH_data)

product.dispose()

Amplitude_VH_data.shape = h, w

imgplot = plt.imshow(Amplitude_VH_data, vmin = 0, vmax = 150) 
imgplot.write_png('Amplitude_VH.png')

#%% Defining some functions

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

#%% Reading more than one product with looping

path = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia' + '**/*.zip'

product_type = 'GRD'

files = glob.glob(path)

files = list(filter(lambda k: product_type in k, files))

print(files)

#%% Reading vector
# For dealing with geospatial data frame and spatial files (as .shp)
import fiona
import gdal
gdal.VersionInfo()

from osgeo import ogr

shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData'

SOC_BW_July_polygon = ogr.Open(shapefile_path + '\\' + 'SOC_BW_NDec_convexHullPolygon.shp')
SOC_BW_July_polygon = SOC_BW_July_polygon.GetLayer(0)

import geopandas as gpd

shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData'

print(shapefile_path + '\SOC_BW_NDec_convexHullPolygon.shp')

SOC_BW_July_polygon = gpd.read_file(
    shapefile_path + '\SOC_BW_NDec_convexHullPolygon.shp')

SOC_BW_July_polygon

SOC_BW_July_polygon = SOC_BW_July_polygon.geometry.to_wkt()

SOC_BW_July_polygon

SOC_BW_NDec_polygon = gpd.read_file(
    shapefile_path+'\SOC_BW_NDec_convexHullPolygon.shp')
SOC_BW_NDec_polygon = SOC_BW_NDec_polygon.geometry.to_wkt()

wkt = str(SOC_BW_July_polygon[0])
projection = '''PROJCS["WGS 84 / UTM zone 23S",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],AUTHORITY["EPSG","32723"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'''

wkt = str(SOC_BW_July_polygon[0])

