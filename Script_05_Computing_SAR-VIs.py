# -*- coding: utf-8 -*-
"""

Code wroten to compute SAR Vegetation Indices using Sentinel-1 GRD post-
processed products.

Created on Thu Jul 21, 2022
Last updated on: Wed Aug 10, 2022

This code is part of the Erli's Ph.D. thesis

Author: Erli Pinto dos Santos
Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

"""

#%% NECESSARY PACKAGES AND MODULES

# For dealing with directories, to collect garbage, and to delete junkeries,
# respectively:
import os
import gc
import shutil
# For listing files within a directory matching name patterns:
import glob
# Fast arrays computation:
import numpy as np
# snappy module to create products:
from snappy import GPF
# snappy module to feed functions with parameters:
from snappy import HashMap
# snappy module to get product metadata:
from snappy import Product
# snappy module to import and export SNAP file formats:
from snappy import ProductIO
# snappy module to get product metadata:
from snappy import ProductData
from snappy import ProductUtils
#from snappy import ProgressMonitor

#%% SETTING WORK DIRECTORY AND READING FILES

# Path where are located the Pre-processed Sentinel-1 GRD
path = r'C:\Users\erlis\OneDrive\Área de Trabalho\Preprocessed_TEST'

# Pattern to match in file names (mainly because at the same folder are
# contained SLC Sentinel-1 archives):
product_type = 'GRD'

# Using glob to read files with '.tif' extension. If data are in '.dim',
# chanche it:
files = glob.glob(path + '**/*.dim')

# Reading and storing found files:
files = list(filter(lambda k: product_type in k, files))

print(files)

#%% DEFINING FUNCTIONS

# Function to compute the CR (Cross-Ratio, Frison et al. (2018)) index,
# using Gamma0 (in dB). If the data is calibrated to Sigma0, change the band name.
def do_cr(source, outpath_):
    
    outpath = str(outpath_)

    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    VH = source.getBand('Gamma0_VH')
    VV = source.getBand('Gamma0_VV')
    
    w = source.getSceneRasterWidth()
    h = source.getSceneRasterHeight()
    
    cr_product = Product('CR', 'CR', w, h)
    cr_band = cr_product.addBand("CR", ProductData.TYPE_FLOAT32)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')

    ProductUtils.copyGeoCoding(source, cr_product)

    cr_product.setProductWriter(writer)
    cr_product.writeHeader(outpath + '\\' + str(source.getName()) + '_CR.dim')

    VH_i = np.zeros(w, dtype = np.float32)
    VV_i = np.zeros(w, dtype = np.float32)

    print("Writing...")

    for y in range(h):
        print("Processing line ", y, " of ", h)
        VH_i = VH.readPixels(0, y, w, 1, VH_i)
        VV_i = VV.readPixels(0, y, w, 1, VV_i)
        
        cr = np.divide(np.multiply(10, np.log10(VV_i)),
                       np.multiply(10, np.log10(VH_i)))
        
        cr_band.writePixels(0, y, w, 1, cr)

    cr_product.closeIO()

    print("Done.")

# Function to compute the DPSVI (Dual-polarization SAR Vegetation Index,
# Periasamy (2018)) (data are/must be in linear power units):
def do_dpsvi(source, outpath_):
    
    outpath = str(outpath_)

    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    VH = source.getBand('Gamma0_VH')
    VV = source.getBand('Gamma0_VV')
    
    w = source.getSceneRasterWidth()
    h = source.getSceneRasterHeight()

    dpsvi_product = Product('DPSVI', 'DPSVI', w, h)
    dpsvi_band = dpsvi_product.addBand("DPSVI", ProductData.TYPE_FLOAT32)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')

    ProductUtils.copyGeoCoding(source, dpsvi_product)

    dpsvi_product.setProductWriter(writer)
    dpsvi_product.writeHeader(outpath + '\\' + str(source.getName()) + '_DPSVI.dim')

    VH_i = np.zeros(w, dtype = np.float32)
    VV_i = np.zeros(w, dtype = np.float32)
    
    print("Writing...")
    
    for y in range(h):
        print("Processing line ", y, " of ", h)
        VH_i = VH.readPixels(0, y, w, 1, VH_i)
        VV_i = VV.readPixels(0, y, w, 1, VV_i)
        
        dpsvi = np.multiply(
            np.multiply(
                # IDPDD:
                np.divide(np.add(np.subtract(np.nanmax(VV_i), VV_i), VH_i), np.sqrt(2)),
                # VDDPI
                np.divide(np.add(VV_i, VH_i), VV_i)),
                # VH band
                VH_i)
        
        dpsvi_band.writePixels(0, y, w, 1, dpsvi)

    dpsvi_product.closeIO()
    
    print("Done.")

# Function to compute the DPSVIm (modified Dual-polarization SAR Vegetation
# Index, dos Santos et al. (2021)) (data are/must be in linear power units):
def do_dpsvim(source, outpath_):
    
    outpath = str(outpath_)

    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    VH = source.getBand('Gamma0_VH')
    VV = source.getBand('Gamma0_VV')
    
    w = source.getSceneRasterWidth()
    h = source.getSceneRasterHeight()

    dpsvim_product = Product('DPSVIm', 'DPSVIm', w, h)
    dpsvim_band = dpsvim_product.addBand("DPSVIm", ProductData.TYPE_FLOAT32)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')

    ProductUtils.copyGeoCoding(source, dpsvim_product)

    dpsvim_product.setProductWriter(writer)
    dpsvim_product.writeHeader(outpath + '\\' + str(source.getName()) + '_DPSVIm.dim')

    VH_i = np.zeros(w, dtype = np.float32)
    VV_i = np.zeros(w, dtype = np.float32)

    print("Writing...")

    for y in range(h):
        print("Processing line ", y, " of ", h)
        VH_i = VH.readPixels(0, y, w, 1, VH_i)
        VV_i = VV.readPixels(0, y, w, 1, VV_i)
        
        dpsvim = np.divide(np.add(np.square(VV_i),
                                  np.multiply(VV_i, VH_i)),
                           np.sqrt(2))
        
        dpsvim_band.writePixels(0, y, w, 1, dpsvim)

    dpsvim_product.closeIO()

    print("Done.")

# Function to compute the normalized polarization (Pol index, Hird et al. (2017))
# (in dB):
def do_pol(source, outpath_):
    
    outpath = str(outpath_)

    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    VH = source.getBand('Gamma0_VH')
    VV = source.getBand('Gamma0_VV')
    
    w = source.getSceneRasterWidth()
    h = source.getSceneRasterHeight()

    pol_product = Product('Pol', 'Pol', w, h)
    pol_band = pol_product.addBand("Pol", ProductData.TYPE_FLOAT32)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')

    ProductUtils.copyGeoCoding(source, pol_product)

    pol_product.setProductWriter(writer)
    pol_product.writeHeader(outpath + '\\' + str(source.getName()) + '_Pol.dim')

    VH_i = np.zeros(w, dtype = np.float32)
    VV_i = np.zeros(w, dtype = np.float32)

    print("Writing...")

    for y in range(h):
        print("Processing line ", y, " of ", h)
        VH_i = VH.readPixels(0, y, w, 1, VH_i)
        VV_i = VV.readPixels(0, y, w, 1, VV_i)
        
        pol = np.divide(
            np.subtract(np.multiply(10, np.log10(VH_i)), np.multiply(10, np.log10(VV_i))),
            np.add(np.multiply(10, np.log10(VH_i)), np.multiply(10, np.log10(VV_i))))
        
        pol_band.writePixels(0, y, w, 1, pol)

    pol_product.closeIO()

    print("Done.")

# Function to compute a modified version of the Radar Vegetation Index (the
# RVIm, modified by Nazi et al. (2019) (data in dB)):
def do_rvim(source, outpath_):
    
    outpath = str(outpath_)

    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    VH = source.getBand('Gamma0_VH')
    VV = source.getBand('Gamma0_VV')
    
    w = source.getSceneRasterWidth()
    h = source.getSceneRasterHeight()

    rvim_product = Product('RVIm', 'RVIm', w, h)
    rvim_band = rvim_product.addBand("RVIm", ProductData.TYPE_FLOAT32)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')

    ProductUtils.copyGeoCoding(source, rvim_product)

    rvim_product.setProductWriter(writer)
    rvim_product.writeHeader(outpath + '\\' + str(source.getName()) + '_RVIm.dim')

    VH_i = np.zeros(w, dtype = np.float32)
    VV_i = np.zeros(w, dtype = np.float32)

    print("Writing...")

    for y in range(h):
        print("Processing line ", y, " of ", h)
        VH_i = VH.readPixels(0, y, w, 1, VH_i)
        VV_i = VV.readPixels(0, y, w, 1, VV_i)
        
        rvim = np.divide(np.multiply(4, np.multiply(10, np.log10(VH_i))),
                         np.add(np.multiply(10, np.log10(VV_i)),
                                np.multiply(10, np.log10(VH_i))))
        
        rvim_band.writePixels(0, y, w, 1, rvim)

    rvim_product.closeIO()

    print("Done.")

# The following function collect the previous (those ones that computes SAR
# indices), define an output folder to store the computed data, and apply each
# function. Remember in changing the outpath variable:
    
################# REMMEMBER IN CHECKING THE OUTPUT DIRECTORY #################
# If the output directory does not exist, os will create it.
def do_sar_vi(_outpath_):
    
    outpath = _outpath_
    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    for i in files:
        
        gc.collect()
        print("Reading...")
        
        product = ProductIO.readProduct(str(i))
        
        w = product.getSceneRasterWidth()
        h = product.getSceneRasterHeight()

        name = product.getName()
        description = product.getDescription()
        band_names = product.getBandNames()

        print("Product:     %s, %s" % (name, description))
        print("Raster size: %d x %d pixels" % (w, h))
        print("Start time:  " + str(product.getStartTime()))
        print("End time:    " + str(product.getEndTime()))
        print("Bands:       %s" % (list(band_names)))
        
        do_cr(product, outpath)
        gc.collect()
        do_dpsvi(product, outpath)
        gc.collect()
        do_dpsvim(product, outpath)
        gc.collect()
        do_pol(product, outpath)
        gc.collect()
        do_rvim(product, outpath)
        gc.collect()

# The following function read the outpath folder, created by the function 
# "do_sar_vi" and merge the files within it folder with its respective original
# product (the Pre-processed Sentinel-1 GRD image):
def do_merge(source, path_):
    
    cr = ProductIO.readProduct(str(str(path_) + '\\' + source.getName() + "_CR.dim"))
    dpsvi = ProductIO.readProduct(str(str(path_) + '\\' + source.getName() + "_DPSVI.dim"))
    dpsvim = ProductIO.readProduct(str(str(path_) + '\\' + source.getName() + "_DPSVIm.dim"))
    pol =  ProductIO.readProduct(str(str(path_) + '\\' + source.getName() + "_Pol.dim"))
    rvim = ProductIO.readProduct(str(str(path_) + '\\' + source.getName() + "_RVIm.dim"))
 
    parameters = HashMap()
    merged_bands = GPF.createProduct('BandMerge', parameters,
                                     (cr, dpsvi, dpsvim, pol, rvim))
    
    cr.dispose()
    cr.closeIO()
    dpsvi.dispose()
    dpsvi.closeIO()
    dpsvim.dispose()
    dpsvim.closeIO()
    pol.dispose()
    pol.closeIO()
    rvim.dispose()
    rvim.closeIO()
    
    del cr
    gc.collect()
    del dpsvi
    gc.collect()
    del dpsvim
    gc.collect()
    del pol
    gc.collect()
    del rvim
    gc.collect()
    
    sourceProducts = HashMap()
    sourceProducts.put('masterProduct', source)
    sourceProducts.put('sourceProduct', merged_bands)

    productMerged = GPF.createProduct('Merge', parameters, sourceProducts)

    return productMerged

# The function "do_merge_and_write" really apply the function "do_merge". It
# works with both an input and output directories. It reads the path where SAR
# Indices are stored (so the Input directory), merge them with its respective
# original product (the Pre-processed Sentinel-1 GRD image); an creates a new
# folder to store the merged files (in BEAM-DIMAP format, which is more fast),
# so the Ouput directory.

#### REMMEMBER IN CHECKING THE DIRECTORIES (INPUT AND OUTPUT DIRECTORIES) ####
# If the output directory does not exist, os will create it.
def do_merge_and_write(_sar_vi_path_, _outpath_):
    
    sar_vi_path = _sar_vi_path_
    
    outpath = _outpath_
    
    if not os.path.exists(outpath):
        os.makedirs(outpath)
        
    for i in files:
        
        gc.collect()
        print("Reading...")
        
        product = ProductIO.readProduct(str(i))

        name = product.getName()
        description = product.getDescription()
        band_names = product.getBandNames()

        print("Product:     %s, %s" % (name, description))
        print("Start time:  " + str(product.getStartTime()))
        print("End time:    " + str(product.getEndTime()))
        print("Bands:       %s" % (list(band_names)))
        
        print("t\Merging...")
        merged_product = do_merge(product, sar_vi_path)
        
        print("New product bands:       %s" % (list(merged_product.getBandNames())))
        print("t\Done!")
        ProductIO.writeProduct(merged_product, outpath + '\\' + name,
                               'BEAM-DIMAP')
        
        product.dispose()
        product.closeIO()
        
        del merged_product
        gc.collect()

#%% APPLYING OPERATORS

# Directory path where the program will store SAR vegetation indices files:
sar_vi_path = r'C:\Users\erlis\OneDrive\Área de Trabalho\ArquivosTemporarios'
# Directory where the program will store merge Sentinel-1 GRD original scenes
# and its derived SAR Vegetation Indices:
outpath = r'C:\Users\erlis\OneDrive\Área de Trabalho\GRD_Processed'

# Applying operators:
do_sar_vi(sar_vi_path)
do_merge_and_write(sar_vi_path, outpath)

gc.collect()

#%% REMOVING JUNKERIE

# As the Dual-pol SAR were compute and merge with its original product, the
# temporary folder can be deleted, in order to save disk space:
shutil.rmtree(str(sar_vi_path))

# As well as the original products:
shutil.rmtree(path)
