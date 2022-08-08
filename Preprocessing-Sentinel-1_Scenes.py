# -*- coding: utf-8 -*-
"""
Created on Mon Jul 18 12:31:14 2022

@author: erlis

"""

#%% Requested modules

import datetime
import time
from snappy import ProductIO
from snappy import HashMap
import os, gc
from snappy import GPF
import geopandas as gpd
import glob 

#%% Importing and dealing with the AOI and Output projection of the scenes
shapefile_path = r'C:\Users\erlis\Documents\MEGA\Projeto_de_pesquisa_Doutorado\Database\VectorData'

print(shapefile_path + '\SOC_BW_NDec_convexHullPolygon.shp')

SOC_BW_July_polygon = gpd.read_file(
    shapefile_path+'\SOC_BW_July_convexHullPolygon.shp')
SOC_BW_July_polygon = SOC_BW_July_polygon.geometry.to_wkt()

SOC_BW_NDec_polygon = gpd.read_file(
    shapefile_path+'\SOC_BW_NDec_convexHullPolygon.shp')
SOC_BW_NDec_polygon = SOC_BW_NDec_polygon.geometry.to_wkt()

wkt = str(SOC_BW_July_polygon[0])
projection = '''PROJCS["WGS 84 / UTM zone 23S",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],AUTHORITY["EPSG","32723"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'''

#%% Reading more than one product with looping

path = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia'

product_type = 'GRD'

files = glob.glob(path + '**/*.zip')

files = list(filter(lambda k: product_type in k, files))

print(files)

files = files[0:2]
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

def main():
    ## All Sentinel-1 data sub folders are located within a super folder (make sure the data is already unzipped and each sub folder name ends with '.SAFE'):
    path = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Raw_scenes'
    outpath = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed'
    
    if not os.path.exists(outpath):
        os.makedirs(outpath)
    ## well-known-text (WKT) file for subsetting (can be obtained from SNAP by drawing a polygon)
    #wkt = 'POLYGON ((-157.79579162597656 71.36872100830078, -155.4447021484375 71.36872100830078, \
    #-155.4447021484375 70.60020446777344, -157.79579162597656 70.60020446777344, -157.79579162597656 71.36872100830078))'
    ## UTM projection parameters
    #proj = '''PROJCS["UTM Zone 4 / World Geodetic System 1984",GEOGCS["World Geodetic System 1984",DATUM["World Geodetic System 1984",SPHEROID["WGS 84", 6378137.0, 298.257223563, AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich", 0.0, AUTHORITY["EPSG","8901"]],UNIT["degree", 0.017453292519943295],AXIS["Geodetic longitude", EAST],AXIS["Geodetic latitude", NORTH]],PROJECTION["Transverse_Mercator"],PARAMETER["central_meridian", -159.0],PARAMETER["latitude_of_origin", 0.0],PARAMETER["scale_factor", 0.9996],PARAMETER["false_easting", 500000.0],PARAMETER["false_northing", 0.0],UNIT["m", 1.0],AXIS["Easting", EAST],AXIS["Northing", NORTH]]'''
    proj = projection
    
    for folder in os.listdir(path):
        gc.enable()
        gc.collect()
        sentinel_1 = ProductIO.readProduct(path + "\\" + folder + "\\manifest.safe")
        print(sentinel_1)

        loopstarttime = str(datetime.datetime.now())
        print('Start time:', loopstarttime)
        start_time = time.time()

        ## Extract mode, product type, and polarizations from filename
        modestamp = folder.split("_")[1]
        productstamp = folder.split("_")[2]
        polstamp = folder.split("_")[3]

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
        
        calibrated = do_calibration(thermaremoved, polarization, pols)
        del thermaremoved
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
            
            down_subset = down_tercorrected#do_subset(down_tercorrected, wkt)
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
            ProductIO.writeProduct(subset, outpath + '\\' + folder[:-5], 'GeoTIFF')
            del subset
            gc.collect()
        elif down == 1:
            print("Writing undersampled image...")
            ProductIO.writeProduct(down_subset, outpath + '\\' + folder[:-5] + '_40', 'GeoTIFF')
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

#%% Main function to do all the pre-processing (2)

processing_steps = '_Orb_NR_Cal_Spk_TF_TC'

def main():
    
    outpath = r'J:\Dados_Raster\Projeto_de_pesquisa_Doutorado\Solos_OesteDaBahia\Preprocessed'
    
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
        
        calibrated = do_calibration(thermaremoved, polarization, pols)
        del thermaremoved
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