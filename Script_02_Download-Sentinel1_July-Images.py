# -*- coding: utf-8 -*-
"""

Code wroten to download Sentinel-1 scenes captured on July, 2017, over
the region Western of the Bahia State (Brazil) using the sampling points.

Created on Wed Jul 13, 2022
Last updated on: Mon July 29, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% Requested packages:

# For data handling
import pandas as pd

# For data viz
import matplotlib.pyplot as plt

# For searching images on Alaska Satellite Facility API 
import asf_search as asf

# For dealing with geospatial data
import geopandas as gpd
from shapely.geometry import MultiPoint, shape
#import numpy as np
#from datetime import dt

#%% Using pandas to import the dataset containing the sampling points:

SOC_BahiaWestern = pd.read_excel(
    io = "C:/Users/erlis/Documents/MEGA/Projeto_de_pesquisa_Doutorado/Database/Solos_Bahia/05_EstoqueC_Dados_campobruto_dionizio_erli.xlsx",
    sheet_name = "atividadeIsabel", skiprows = 1
    )

# As in this script I want only to get July scenes, the following command
# creates a new variable for storing the month of the sample. It do it throught
# pandas Series.dt properties of datetime structured data:
SOC_BahiaWestern['month'] = SOC_BahiaWestern['DATA'].dt.month

SOC_BW_July = SOC_BahiaWestern[SOC_BahiaWestern.month == 7]

#%% Transforming the data frame in a GeoDataFrame

SOC_BW_July = gpd.GeoDataFrame(
    SOC_BW_July,
    geometry = gpd.points_from_xy(SOC_BW_July.LON, SOC_BW_July.LAT)
    )

aoi = gpd.GeoSeries(MultiPoint(SOC_BW_July['geometry']))
aoi = aoi.convex_hull

#aoi.plot()
#SOC_BW_July.plot()
#plt.show()

#%% Searching Sentinel-1 images in the AOI area

opts = {
    'platform': asf.PLATFORM.SENTINEL1,
    'start': '2017-07-01T00:00:00Z',
    'end': '2017-08-01T23:59:59Z',
    'relativeOrbit': [126, 24],
    'processingLevel': 'GRD_HD' #'SLC' 
}

results = asf.geo_search(intersectsWith = str(aoi[0]), **opts)

print(f'{len(results)} results found')

#%% Visualizing imagery footprint

results_index = 2

footprint = gpd.GeoSeries(shape(results[results_index].geometry))

f, ax = plt.subplots(1)
gpd.plotting.plot_series(footprint, ax = ax)
for points in SOC_BW_July['geometry']:
    gpd.plotting.plot_point_collection(ax, SOC_BW_July['geometry'],
                                       facecolor = "darkblue", alpha = 0.3)

#print(f'Granule search example: {results}')
print(f'ASFSearchResults serializes to geojson: {results[results_index]}')

#a = results[results_index]
#print(results[results_index])

#%% Exporting footprints

orbit_126_footprint_1_july = gpd.GeoSeries(shape(results[3].geometry))
orbit_126_footprint_1_july.to_file(
    r"C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData\Sentinel-1_GRD_Footprints\orbit_126_footprint_1_july.shp")

orbit_126_footprint_2_july = gpd.GeoSeries(shape(results[2].geometry))
orbit_126_footprint_2_july.to_file(
    r"C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData\Sentinel-1_GRD_Footprints\orbit_126_footprint_2_july.shp")

#%% Visualizing imagery footprint

footprint = gpd.GeoSeries(shape(results[0].geometry))

x, y = footprint.exterior.xy

plt.plot(x, y, c = "red")+SOC_BahiaWestern.plot()
plt.show()

#%% Log in ASF Data Vertex to download selected images

session = asf.ASFSession()

try:
    user_pass_session = asf.ASFSession().auth_with_creds("Erli", "Parabellum22")
except asf.ASFAuthenticationError as e:
    print(f'Auth failed: {e}')
else:
    print('Success!')

#%% Downloading single products

from os import listdir

results[results_index].download(path = "C:/Users/erlis/Documents/Sentinel1_over_BahiaWestern",
                                session = user_pass_session)

listdir("C:/Users/erlis/Documents/Sentinel1_over_BahiaWestern")

#%% Downloading multiple products

from os import listdir

results[2:3].download(path = "C:/Users/erlis/Documents/Sentinel1_over_BahiaWestern",
                      session = user_pass_session,
                      processes = 50)

listdir("C:/Users/erlis/Documents/Sentinel1_over_BahiaWestern")
