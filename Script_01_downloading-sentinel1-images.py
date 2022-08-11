# -*- coding: utf-8 -*-
"""

Code wroten to download Sentinel-1 scenes via geographical search using the
Alaska Satellite Facility module.
    Inputs: Excel sheet with point samples (geographic coordinates) and
    searching parameters;
    Output: Selected Sentinel-1 scenes.

WARNING:
    The first part of this script only deal with Excel files containing
    geographical points. Then a convex hull polygon is created based on
    filtered point coordinates.
    If you already has a polygon to do your geographical search, just step the
    first part.
    
Created on Wed Jul 13, 2022
Last updated on: Thu Aug 11, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% REQUESTED MODULES

# For data handling (including dealing with Excel files)
import pandas as pd
# For dealing with directories
from os import listdir
# For data viz
import matplotlib.pyplot as plt
# For searching images on Alaska Satellite Facility API 
import asf_search as asf
# For dealing with geospatial data (including geo data frames)
import geopandas as gpd
from shapely.geometry import MultiPoint, shape

#%% USING PANDAS TO IMPORT THE DATASET CONTAINING SAMPLING POINTS:

file_path = r'C:/Users/erlis/Documents/MEGA/Projeto_de_pesquisa_Doutorado/Database/Solos_Bahia'

# As my geographic coordinates are stored in a Excel file, I'm importing it
# as a pandas object:
SOC_BahiaWestern = pd.read_excel(
    io = file_path + '\\' + "05_EstoqueC_Dados_campobruto_dionizio_erli.xlsx",
    sheet_name = "atividadeIsabel", skiprows = 1
    )

# As the coordinates are labeled with the date (moth) which them were
# collected, and in this script I want search images based on the date
# of the points, the following command creates a new variable for storing the
# month of the sample. It do it throught pandas Series.dt properties of
# datetime structured data: 
SOC_BahiaWestern['month'] = SOC_BahiaWestern['DATA'].dt.month

#%% TRANSFORMING THE DATA FRAME IN A GEODATAFRAME

SOC_BahiaWestern = gpd.GeoDataFrame(
    SOC_BahiaWestern,
    geometry = gpd.points_from_xy(SOC_BahiaWestern.LON, SOC_BahiaWestern.LAT)
    )

# Creating the AOI via convex hull polygon:
aoi = gpd.GeoSeries(MultiPoint(SOC_BahiaWestern['geometry']))
aoi = aoi.convex_hull

#aoi.plot()
#SOC_BahiaWestern.plot()
#plt.show()

#%% SEARCHING SENTINEL-1 IMAGES WHICH INTERSECTS THE AOI POLYGON

# Setting searching options:
opts = {
    'platform': asf.PLATFORM.SENTINEL1,
    'start': '2017-11-01T00:00:00Z',
    'end': '2017-12-01T23:59:59Z',
    'relativeOrbit': 126, #24,#
    'processingLevel':  'GRD_HD' #'SLC' 
}

# Doing the geographical search:
results = asf.geo_search(intersectsWith = str(aoi[0]), **opts)

print(f'{len(results)} results found')

#%% VISUALIZING BOTH A SELECTED IMAGE FOOTPRINT AND THE SEARCH POLYGON

# Set a index for selecting a item in the results object:
results_index = 8

# Getting a image footprint:
footprint = gpd.GeoSeries(shape(results[results_index].geometry))

f, ax = plt.subplots(1)
gpd.plotting.plot_series(footprint, ax = ax)
for points in SOC_BahiaWestern['geometry']:
    gpd.plotting.plot_point_collection(ax, SOC_BahiaWestern['geometry'],
                                       facecolor = "darkblue", alpha = 0.3)

#print(f'Granule search example: {results}')
print(f'ASFSearchResults serializes to geojson: {results[results_index]}')

#a = results[results_index]
print(results[results_index])

#%% LOG IN ASF DATA VERTEX TO DOWNLOAD THE SELECTED IMAGES

# Initiating session:
session = asf.ASFSession()

try:
    user_pass_session = asf.ASFSession().auth_with_creds("Erli", "Parabellum22")
except asf.ASFAuthenticationError as e:
    print(f'Auth failed: {e}')
else:
    print('Success!')

#%% USE THIS CHUNK TO DOWNLOAD A SINGLE PRODUCT

# Directory to save the image:
outpath = r'I:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Level_1'

results[results_index].download(path = str(outpath), session = user_pass_session)

listdir(outpath)

#%% USE THIS CHUNK TO DOWNLOAD MULTIPLE PRODUCTS

outpath = r'I:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Level_1'

results[8:11].download(path = str(outpath), session = user_pass_session)

listdir(outpath)
