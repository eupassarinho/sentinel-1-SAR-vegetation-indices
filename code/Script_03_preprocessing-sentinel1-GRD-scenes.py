# -*- coding: utf-8 -*-
"""

Code wroten to perform pre-processing of Sentinel-1 scenes. The goal is to do:
    Apply Orbit File > Remove Thermal Noise > Remove GRD Border Noise >
    Calibrate products > perform Speckle Noise Filtering > Radiometric
    Terrain Flattening > and to Terrain Correction (with an optional resampling).

Created on Mon Jul 18, 2022
Last updated on: Sat Feb 18, 2023

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% REQUESTED MODULES

# For listing files within a directory matching name patterns:
import glob
# To known processing time:
import time
# For dealing with directories and to collect garbage
import os, gc
# To deal with date formats
import datetime
# snappy module to create products:
from snappy import GPF
# snappy module to feed functions with parameters:
from snappy import HashMap
# snappy module to import and export SNAP file formats:
from snappy import ProductIO

#%% READING MULTIPLE PRODUCTS ('.zip') WITH GLOB LOOPING

# Path where Sentinel-1 just got ('.zip') were located:
inpath = r'C:\Users\erlis\OneDrive\Área de Trabalho\Dados_Isabel_Erli\GRD_Level_1'

# Only Ground Range Detected images:
product_type = 'GRD'

# Note that only ".zip" files will be search, i.e., the files as downloaded in
# the Script 01:
files = glob.glob(inpath + '**/*.zip')

files = list(filter(lambda k: product_type in k, files))

# Printing all found files:
print(files)

#%% DEFINING THE OUTPUT PROJECTION FOR SENTINEL-1 SCENES

projection = '''PROJCS["WGS 84 / UTM zone 23S",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],AUTHORITY["EPSG","32723"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'''

#%% SETTING FUNCTIONS TO DO THE PREPROCESSING

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
    parameters.put('filter', 'Lee Sigma')
    parameters.put('Sigma', 0.9)
    parameters.put('filterSizeX', 11)
    parameters.put('filterSizeY', 11)
    output = GPF.createProduct('Speckle-Filter', parameters, source)
    return output

def do_radiometric_terrain_flattening(source):
    print('\tRadiometric terrain flattening...')
    parameters = HashMap()
    parameters.put('demName', 'SRTM 1Sec HGT')
    parameters.put('imgResamplingMethod', 'BILINEAR_INTERPOLATION')
    parameters.put('oversamplingMultiple', 4.0)
    output = GPF.createProduct('Terrain-Flattening', parameters, source)
    return output

def do_terrain_correction(source, proj, downsample):
    print('\tTerrain correction...')
    parameters = HashMap()
    parameters.put('demName', 'SRTM 1Sec HGT')
    parameters.put('demResamplingMethod', 'BILINEAR_INTERPOLATION')
    # comment the following line if no need to convert to UTM/WGS84 (default is WGS84)
    parameters.put('mapProjection', proj)
    parameters.put('saveIncidenceAngleFromEllipsoid', False)
    parameters.put('saveProjectedLocalIncidenceAngle', False)
    parameters.put('saveSelectedSourceBand', True)
    # downsample: 1 -- need downsample to 40m, 0 -- no need to downsample
    while downsample == 1:   
        parameters.put('pixelSpacingInMeter', 40.0)
        break
    output = GPF.createProduct('Terrain-Correction', parameters, source)
    return output

#%% SETTING THE MAIN FUNCTION TO DO ALL THE PREPROCESSING LOOPING WITH FILES

# String to add to product name once the processing is finished:
processing_steps = '_Orb_NR_Brd_Cal_Spk_TF_TC'

# Setting main function:

def main(_outpath_):
    
    # If the output directory does not exist, make it:
    if not os.path.exists(_outpath_):
        os.makedirs(_outpath_)
    
    ## UTM projection parameters (above defined):
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
        #modestamp = product_name.split("_")[1]
        #productstamp = product_name.split("_")[2]
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
        
        terrain_flattened = do_radiometric_terrain_flattening(down_filtered)
        
        del down_filtered
        gc.collect()
        
        tercorrected = do_terrain_correction(terrain_flattened, proj, 0)
        
        del terrain_flattened
        gc.collect()
        
        print("Writing...")
        ProductIO.writeProduct(tercorrected, _outpath_ + '\\' + product_name + processing_steps,
                               'BEAM-DIMAP')
        
        print('Done.')
        sentinel_1.dispose()
        sentinel_1.closeIO()
        
        print("--- %s seconds ---" % (time.time() - start_time))

#%% DOING PREPROCESSING

# Define your output directory (where the preprocessed scenes shall be saved):
outpath = r'C:\Users\erlis\OneDrive\Área de Trabalho\Dados_Isabel_Erli\GRD_Level_1_Preprocessed'

if __name__== "__main__":
    main(outpath)

