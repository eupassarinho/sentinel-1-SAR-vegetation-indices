# -*- coding: utf-8 -*-
"""

Code wroten to perform cropping of Sentinel-1 scenes.
    Inputs: Sentinel-1 GRD preprocessed scenes in BEAM-DIMAP format; shapefile
    with Area of Interest (with datum: WGS84 and not projected (decimal degree
    coordinate system));
    Outputs: Sentinel-1 GRD preprocessed cropped scenes.

Created on Thu Aug 09, 2022
Last updated on: Thu Aug 11, 2022

This code is part of the Erli Pinto dos Santos' Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% REQUESTED MODULES

# For dealing with directories, to collect garbage, and to delete junkeries,
# respectively:
import os
import gc
import shutil
# For listing files within a directory matching name patterns:
import glob
# To known processing time:
import time
# To deal with date formats
import datetime
# For dealing with geospatial data frame and spatial files (as .shp)
import geopandas as gpd
# snappy module:
import snappy
# snappy module to import/export SNAP file formats, and to set
# WKT (Well-Known-Text) Area of Interest (AOI):
from snappy import ProductIO, WKTReader

#%% READING MULTIPLE PRODUCTS ('.dim') WITH GLOB LOOPING

# Path where Sentinel-1 preprocessed images ('.dim') were located:
inpath = r'I:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed'

# Only Ground Range Detected images:
product_type = 'GRD'

files = glob.glob(inpath + '**/*.dim')

files = list(filter(lambda k: product_type in k, files))

# Printing all found files:
print(files)

#%% IMPORTING AOI (Area of Interest) TO BE USED IN SUBSETTING

# I shall advise you that the AOI shapefile should not be projected, I mean, it
# is mandatory to have it in WGS 84 datum and with decimal degree coordinates.
# Even if your scenes are projected to any UTM Zone, the SNAP engine will
# understand and make the subsetting.

# Directory where the aoi shapefile is located:
shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData'

# Importing aoi shapefile as a geopandas object:
aoi = gpd.read_file(shapefile_path + '\SOC_BW_July_convexHullPolygon.shp')
# Casting the aoi from geopandas to a gpd.Series object:
aoi = aoi.geometry.to_wkt()
# Casting the aoi from gpd.Series to a WKT (Well-Known-Text) format:
aoi = aoi[0]

#%% SUBSETTING SCENES WITH LOOPING

# Directory to save the cropped products:
outpath = r'I:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\PreprocessedAndCropped'

if not os.path.exists(outpath):
    os.makedirs(outpath)

# Getting the subset operator:
SubsetOp = snappy.jpy.get_type('org.esa.snap.core.gpf.common.SubsetOp')
geom = WKTReader().read(aoi)

# Applying subset operator:
for i in files:
    
    gc.enable()
    gc.collect()
    
    print("Reading...")
    
    sentinel_1 = ProductIO.readProduct(str(i))
    product_name = sentinel_1.getName()
    print("Product:", product_name)

    loopstarttime = str(datetime.datetime.now())
    print('Start time:', loopstarttime)
    start_time = time.time()

    ## Start subsetting:
    op = SubsetOp()
    op.setSourceProduct(sentinel_1)
    op.setGeoRegion(geom)
    op.setCopyMetadata(True)
    
    sub_product = op.getTargetProduct()

    print("Writing...")
    ProductIO.writeProduct(sub_product, outpath + '\\' + product_name + "_sub",
                           "BEAM-DIMAP")
    print("Done.")    
    
    sentinel_1.dispose()
    sentinel_1.closeIO()
    del sentinel_1
    gc.collect()
    sub_product.dispose()
    sub_product.closeIO()
    del sub_product
    gc.collect()
    
    print("--- %s seconds ---" % (time.time() - start_time))
    
#%% REMOVING JUNKERIE

# As the crop and export were already applied, the following command will
# delete the original files (the preprocessed scenes):
shutil.rmtree(inpath)
