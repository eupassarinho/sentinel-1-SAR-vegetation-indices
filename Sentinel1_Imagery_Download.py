# -*- coding: utf-8 -*-
"""
Created on: Mon July 11, 2022
Last updated on: Mon July 12, 2022

@author: Erli Pinto dos Santos

"""

# import pip 

#%% Requested packages
# import asf_tools as asf

import asf_search as asf
import pandas as pd
import numpy as np
import descartes
import geopandas as gpd
from geopandas import datasets
from geopandas import GeoSeries
import matplotlib.pyplot as plt
from shapely.geometry import Polygon, LineString, Point, MultiPoint
from shapely.geometry import shape
import folium
import mapclassify 
import plotly.express as px

#%% Getting used to the "asf_search"

print(asf.__version__)

results = asf.search(platform = asf.PLATFORM.SENTINEL1, maxResults = 5)

print(results)

print(asf.PLATFORM.RADARSAT)

results[0].geometry().print()

print(asf.PLATFORM)

'C:/Users/erlis/AppData/Roaming/Python/Python39/site-packages/asf_search/constants/PLATFORM.py'

#%% Importing geometries to do geographical search using ASF

SOC_BahiaWestern = pd.read_excel(
    io = "C:/Users/erlis/Documents/MEGA/Projeto_de_pesquisa_Doutorado/Database/Solos_Bahia/05_EstoqueC_Dados_campobruto_dionizio_erli.xlsx",
    sheet_name = "atividadeIsabel", skiprows = 1
    )

SOC_BahiaWestern = SOC_BahiaWestern.iloc[:,[1, 2, 3, 4, 5, 6, 7, 8]]

SOC_BahiaWestern = gpd.GeoDataFrame(
    SOC_BahiaWestern,
    geometry = gpd.points_from_xy(SOC_BahiaWestern.LON, SOC_BahiaWestern.LAT)
    )

aoi = gpd.GeoSeries(MultiPoint(SOC_BahiaWestern['geometry']))
aoi = aoi.convex_hull

aoi.plot()
SOC_BahiaWestern.plot()
plt.show()


#%% Searching Sentinel-1 images in the AOI area

opts = {
    'platform': asf.PLATFORM.SENTINEL1,
    'start': '2017-07-01T00:00:00Z',
    'end': '2017-08-01T23:59:59Z',
    'relativeOrbit': [126, 24]
}

results = asf.geo_search(intersectsWith = str(aoi[0]), **opts)

print(f'{len(results)} results found')

#print(f'Granule search example: {results}')
print(f'ASFSearchResults serializes to geojson: {results[1]}')

#%% Visualizing imagery footprint

footprint = gpd.GeoSeries(shape(results[0].geometry))

x, y = footprint.exterior.xy

plt.plot(x, y, c = "red")+SOC_BahiaWestern.plot()
plt.show()

