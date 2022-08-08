# -*- coding: utf-8 -*-
"""

Code wroten to perform pre-processing of Sentinel-1 scenes. The goal is to do:
    Apply Orbit File > Remove Thermal Noise > Remove GRD Border Noise >
    Calibrate products > perform Speckle Noise Filtering > Radiometric
    Terrain Flattening > Terrain Correction > and to Subset scene (optional).

Created on Mon Jul 18, 2022
Last updated on: Thu July 25, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% Requested modules

# For listing files within a directory matching name patterns:
import glob
# To known processing time:
import time
# For dealing with directories and to collect garbage
import os, gc
# To deal with date formats
import datetime
# For dealing with geospatial data frame and spatial files (as .shp)
import geopandas as gpd

# snappy module to create products:
from snappy import GPF
# snappy module to feed functions with parameters:
from snappy import HashMap
# snappy module to import and export SNAP file formats:
from snappy import ProductIO

#%% Importing and dealing with the AOI and Output projection of the scenes
#shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData'

#print(shapefile_path + '\SOC_BW_NDec_convexHullPolygon.shp')

#SOC_BW_July_polygon = gpd.read_file(
#    shapefile_path+'\SOC_BW_July_convexHullPolygon.shp')

#SOC_BW_July_polygon = SOC_BW_July_polygon.geometry.to_wkt()

#polygon = SOC_BW_July_polygon.geometry.to_wkt()
#envelope_polygon = SOC_BW_July_polygon.geometry.envelope.to_wkt()
#envelope_polygon = str(envelope_polygon[0])

#SOC_BW_NDec_polygon = gpd.read_file(
#    shapefile_path+'\SOC_BW_NDec_convexHullPolygon.shp')
#SOC_BW_NDec_polygon = SOC_BW_NDec_polygon.geometry.to_wkt()

#wkt = str(SOC_BW_July_polygon[0])

projection = '''PROJCS["WGS 84 / UTM zone 23S",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],AUTHORITY["EPSG","32723"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'''

#%% Reading more than one product with looping

path = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia'

product_type = 'GRD'

files = glob.glob(path + '**/*.zip')

files = list(filter(lambda k: product_type in k, files))

print(files)

#%% Creating functions

def do_apply_orbit_file(source):
    print('\tApply orbit file...')
    parameters = HashMap()
    parameters.put('Apply-Orbit-File', True)
    output = GPF.createProduct('Apply-Orbit-File', parameters, source)
    return output

def do_thermal_noise_removal(source):
    print('\tThermal noise removal...')
    parameters = HashMap()
    parameters.put('removeThermalNoise', True)
    output = GPF.createProduct('ThermalNoiseRemoval', parameters, source)
    return output

def do_grd_border_noise_removal(source):
    print('\tRemove GRD Border Noise...')
    parameters = HashMap()
    parameters.put('borderMarginLimit', 600)
    parameters.put('threshold', 0.5)
    output = GPF.createProduct('Remove-GRD-Border-Noise', parameters, source)
    return output

def do_calibration(source, polarization, pols):
    print('\tCalibration...')
    parameters = HashMap()
    # I'm changing the output to beta naught, the original code generates an
    # output in sigma as follows:
    #parameters.put('outputSigmaBand', True)
    parameters.put('outputBetaBand', True)
    if polarization == 'DH':
        parameters.put('sourceBands', 'Intensity_HH,Intensity_HV')
    elif polarization == 'DV':
        parameters.put('sourceBands', 'Intensity_VH,Intensity_VV')
    elif polarization == 'SH' or polarization == 'HH':
        parameters.put('sourceBands', 'Intensity_HH')
    elif polarization == 'SV':
        parameters.put('sourceBands', 'Intensity_VV')
    else:
        print("different polarization!")
    parameters.put('selectedPolarisations', pols)
    parameters.put('outputImageScaleInDb', False)
    output = GPF.createProduct("Calibration", parameters, source)
    return output

def do_speckle_filtering(source):
    print('\tSpeckle filtering...')
    parameters = HashMap()
    parameters.put('filter', 'Lee')
    parameters.put('filterSizeX', 5)
    parameters.put('filterSizeY', 5)
    output = GPF.createProduct('Speckle-Filter', parameters, source)
    return output

def do_radiometric_terrain_flattening(source):
    print('\tRadiometric terrain flattening...')
    parameters = HashMap()
    parameters.put('demName', 'SRTM 1Sec HGT')
    parameters.put('imgResamplingMethod', 'BILINEAR_INTERPOLATION')
    output = GPF.createProduct('Terrain-Flattening', parameters, source)
    return output

def do_terrain_correction(source, proj, downsample):
    print('\tTerrain correction...')
    parameters = HashMap()
    parameters.put('demName', 'SRTM 1Sec HGT')
    parameters.put('demResamplingMethod', 'BILINEAR_INTERPOLATION')
    # comment the following line if no need to convert to UTM/WGS84 (default is WGS84)
    parameters.put('mapProjection', proj)       
    parameters.put('saveProjectedLocalIncidenceAngle', True)
    parameters.put('saveSelectedSourceBand', True)
    # downsample: 1 -- need downsample to 40m, 0 -- no need to downsample
    while downsample == 1:   
        parameters.put('pixelSpacingInMeter', 10.0)
        break
    output = GPF.createProduct('Terrain-Correction', parameters, source)
    return output

def do_subset(source, wkt):
    print('\tSubsetting...')
    parameters = HashMap()
    parameters.put('geoRegion', wkt)
    output = GPF.createProduct('Subset', parameters, source)
    return output

#%% Main function to do all the pre-processing

processing_steps = '_Orb_NR_Brd_Cal_Spk_TF_TC'

def main():
    
    outpath = r'F:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed'
    
    if not os.path.exists(outpath):
        os.makedirs(outpath)
    
    ## UTM projection parameters
    proj = projection
    
    for i in files:
        gc.enable()
        gc.collect()
        sentinel_1 = ProductIO.readProduct(str(i))
        product_name = sentinel_1.getName()
        print(sentinel_1)

        loopstarttime = str(datetime.datetime.now())
        print('Start time:', loopstarttime)
        start_time = time.time()

        ## Extract mode, product type, and polarizations from filename
        modestamp = product_name.split("_")[1]
        productstamp = product_name.split("_")[2]
        polstamp = product_name.split("_")[3]
        
        polarization = polstamp[2:4]
        if polarization == 'DV':
            pols = 'VH,VV'
        elif polarization == 'DH':
            pols = 'HH,HV'
        elif polarization == 'SH' or polarization == 'HH':
            pols = 'HH'
        elif polarization == 'SV':
            pols = 'VV'
        else:
            print("Polarization error!")

        ## Start preprocessing:
        applyorbit = do_apply_orbit_file(sentinel_1)
        thermaremoved = do_thermal_noise_removal(applyorbit)
        del applyorbit
        gc.collect()
        
        borderRemoved = do_grd_border_noise_removal(thermaremoved)
        del thermaremoved
        gc.collect()
        
        calibrated = do_calibration(borderRemoved, polarization, pols)
        del borderRemoved
        gc.collect()
        
        down_filtered = do_speckle_filtering(calibrated)
        del calibrated
        gc.collect()
        
        terrain_flat = do_radiometric_terrain_flattening(down_filtered)
        
        ## IW images are downsampled from 10m to 40m (the same resolution as EW images).
        if (modestamp == 'IW' and productstamp == 'GRDH') or (modestamp == 'EW' and productstamp == 'GRDH'):
            down_tercorrected = do_terrain_correction(terrain_flat, proj, 1)
            
            del terrain_flat
            gc.collect()
            
            down_subset = down_tercorrected #do_subset(down_tercorrected, wkt)
            del down_filtered
            del down_tercorrected
        elif modestamp == 'EW' and productstamp == 'GRDM':
            tercorrected = do_terrain_correction(down_filtered, proj, 0)
            subset = do_subset(tercorrected, wkt)
            del down_filtered
            gc.collect()
            del tercorrected
            gc.collect()
        else:
            print("Different spatial resolution is found.")

        down = 1
        try: down_subset
        except NameError:
            down = None
        if down is None:
            print("Writing...")
            ProductIO.writeProduct(subset, outpath + '\\' + product_name + processing_steps,
                                   'GeoTIFF-BigTIFF')
            del subset
            gc.collect()
        elif down == 1:
            print("Writing undersampled image...")
            ProductIO.writeProduct(down_subset, outpath + '\\' + product_name + processing_steps + '_10m',
                                   'GeoTIFF-BigTIFF')
            del down_subset
            gc.collect()
        else:
            print("Error.")

        print('Done.')
        sentinel_1.dispose()
        sentinel_1.closeIO()
        print("--- %s seconds ---" % (time.time() - start_time))

if __name__== "__main__":
    main()

#%% Reading more than one product with looping

outpath = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed'

product_type = 'GRD'

files = glob.glob(outpath + '**/*.tif')

files = list(filter(lambda k: product_type in k, files))

print(files)

#%% Subsetting scenes
import jpy

shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData\Sentinel-1_GRD_Footprints'

roi_1 = gpd.read_file(shapefile_path + '\orbit_126_footprint_1_july.shp')

roi_1 = roi_1.geometry.to_wkt()

def do_subset(source, geom):
    print('\tMasking...')

    WKTReader = jpy.get_type('org.locationtech.jts.io.WKTReader')
    
    polygon = WKTReader().read(geom)
    
    GPF.getDefaultInstance().getOperatorSpiRegistry().loadOperatorSpis()
    parameters = HashMap()
    parameters.put('copyMetadata', True)
    parameters.put('geoRegion', polygon)
    output = GPF.createProduct('Subset', parameters, source)
    return output

def do_subset_rectangle(source, wkt):
    print('\tMasking...')
    
    #polygon = 'POLYGON ((-45.89632476291466 -11.544419900904112, -45.32270461658675 -11.545624269433658, -45.32303839877719 -11.833750492852037, -45.89725172422871 -11.83251524058129, -45.89632476291466 -11.544419900904112))'
    parameters = HashMap()
    parameters.put('copyMetadata', True)
    parameters.put('geoRegion', str(wkt))
    output = GPF.createProduct("Subset", parameters, source)
    return output

sentinel_1 = ProductIO.readProduct(str(files[0]))

print(sentinel_1.getName())
print(sentinel_1.getSceneRasterWidth())

sentinel_1 = do_subset(sentinel_1, roi_1)

print(sentinel_1.getSceneRasterWidth())


for i in files:
    
    gc.enable()
    gc.collect()

    WKTReader = jpy.get_type('org.locationtech.jts.io.WKTReader')
    geom = WKTReader().read(wkt)
        
    loopstarttime = str(datetime.datetime.now())
    print('Start time:', loopstarttime)
    start_time = time.time()
    
    sentinel_1 = ProductIO.readProduct(str(i))
    product_name = sentinel_1.getName()

    print('Subsetting scene:', product_name)
    
    subset = do_subset(sentinel_1, geom)
    
    del sentinel_1
    gc.collect()

    print("Writing cropped image...")
    
    ProductIO.writeProduct(subset, outpath + '\\' + product_name + '_subset', 'GeoTIFF-BigTIFF')

    del subset
    gc.collect()

    print('Done.')
    
    print("--- %s seconds ---" % (time.time() - start_time))

#%%

sentinel_1 = ProductIO.readProduct(str(files[0]))
product_name = sentinel_1.getName()
product_name

WKTReader = jpy.get_type('org.locationtech.jts.io.WKTReader')

gc.enable()

geom = WKTReader().read(wkt)


def do_land_sea_mask(source, wkt):
    print('\tMasking...')
    parameters = HashMap()
    parameters.put('setGeoRegion', wkt)
    output = GPF.createProduct('Subset', parameters, source)
    return output


subset = do_land_sea_mask(sentinel_1, geom)

#%% Defining some functions

import numpy as np
import matplotlib as plt

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

plotBand(subset, "Gamma0_VH", 0, 0.1)
