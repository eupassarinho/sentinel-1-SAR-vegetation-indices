# -*- coding: utf-8 -*-
"""
Created on Mon Feb 27 13:22:10 2017

@author: ryan
"""

import sys
import os
from snappy import (Product,ProductUtils, ProgressMonitor, VectorDataNode,
                    WKTReader, ProductIO, PlainFeatureFactory,
                    SimpleFeatureBuilder, DefaultGeographicCRS,
                    ListFeatureCollection, FeatureUtils)
import numpy as np

def add_wkt_vector_geom(product, geom_name, polygons_wkt):
    """This method creates a new vector container with the wkt_cords 
    to the vector node of the product.
    TODO: overload this method to allow addition of vectors from shapefile
    (see add_shape_vector_to_product())
    """
    geom = WKTReader().read(polygons_wkt)
    
    wktFeatureType = PlainFeatureFactory.createDefaultFeatureType(DefaultGeographicCRS.WGS84)
    featureBuilder = SimpleFeatureBuilder(wktFeatureType)
    wktFeature = featureBuilder.buildFeature(str(geom_name))
    wktFeature.setDefaultGeometry(geom)
    
    newCollection = ListFeatureCollection(wktFeatureType)
    newCollection.add(wktFeature)
    
    #this looks like it edits features to ensure they are in the raster bounding box
    productFeatures = FeatureUtils.clipFeatureCollectionToProductBounds(newCollection, product, None, ProgressMonitor.NULL)
    
    node = VectorDataNode(str(geom_name), productFeatures)
    print ('Num features = ', node.getFeatureCollection().size())
    product.getVectorDataGroup().add(node)
    
    vdGroup = product.getVectorDataGroup()
    for i in range(vdGroup.getNodeCount()):
        print('Vector data = ', vdGroup.get(i).getName())
#        
    maskGroup = product.getMaskGroup()
    for i in range(maskGroup.getNodeCount()):
        print('Mask = ', maskGroup.get(i).getName())
        
    return product 

    
    
def get_masked_product_from_wkt(product, polygons_wkt):
    """Here we try and mask using a wkt"""
    
    #add the wkt geometry to the product using a seperate method which returns a product with added vector
    geom_name = 'shape'
    src_product = add_wkt_vector_geom(product, geom_name, polygons_wkt)        
    
    #get dimensions
    w = src_product.getSceneRasterWidth()
    h = src_product.getSceneRasterHeight()
    band_names = src_product.getBandNames()
    
    #createa new empty 'mask' product
    out_product = Product('masked', 'masked', w, h)
    ProductUtils.copyGeoCoding(src_product, out_product)
    writer = ProductIO.getProductWriter('BEAM-DIMAP')
    out_product.setProductWriter(writer)
            
    #apply to all bands
    for band_name in band_names:
        print('defining output bands:', band_name)
        ProductUtils.copyBand(band_name, src_product, out_product, False) # assuming the bands are already Float32
    
    ## first the bands must be defined, then we can write the header
    out_product.writeHeader('masked_product.dim')        
    
    #THIS DOESNT SEEM NEEDED ANYMORE...
    geom_mask = src_product.getMaskGroup().get(geom_name) 
   
#        geom_mask.setOwner(src_product)
#        valid_mask_image = geom_mask.getValidMaskImage()        
#        mask_image = geom_mask.getSourceImage()
    
    #apply to all bands
    for band_name in band_names:
        print('reading band:', band_name)
        #add a band to be masked
        src_band = src_product.getBand(band_name)
        out_band = out_product.getBand(band_name)
        #set the band noData values
        out_band.setNoDataValue(np.nan)
        out_band.setNoDataValueUsed(True)
        
        #create an empty data array
        data_array = np.zeros(shape=(w, h), dtype=np.float32)
        #read the pixels (to be masked) into the array
        src_band.readPixels(0, 0, w, h, data_array)
    
        """TROUBLE HERE TRYING TO READ IN BAND AS MASK ARRAY"""
        #array for mask values
        mask_array = np.zeros(shape=(w, h), dtype=np.int32) 
        
        src_band.setValidPixelExpression(str(geom_name) +'== 0')
        src_band.setNoDataValue(np.nan)
        src_band.setNoDataValueUsed(True)
        
        src_band.getValidMaskImage()
    
        #read the mask pixels into an mask array
        src_band.readValidMask(0, 0, w, h, mask_array)
        
        # create a numpy mask condition
        invalid_mask = np.where(mask_array == 0, 1, 0)
        #apply the mask array to our data array using numpy
        masked_data = np.ma.array(data_array, mask=invalid_mask, fill_value=np.nan)
        #write the masked band back into the band
        out_band.writePixels(0, 0, w, h, masked_data)
    
    # write changed header again
    out_product.writeHeader('masked_product.dim')
    
    print('Masking finished')
    
    return out_product
    
    
    
if __name__ == '__main__':
    
    working_folder = r'C:\Users\user_name\Documents\sentinel_1'
    #point at the folder containing your raw files
    product = os.path.join(working_folder, 'farm_stack_20170216_171548_bb283670-8d8a-4a99-9f98-37925b8ba244.dim')
    target = os.path.join(working_folder, 'masked_product_test.dim')
    #this can be any folder you like that wil acts as your root workspace
#    rootWorkSpace=r'C:\Users\ryan.elfman\Documents\Innovate_EOforAgri\Soil_Moisture'
    
        
    polygons_wkt = 'POLYGON ((-0.405545914420316 51.8237467815324,-0.353673664493215 51.8237467815324,-0.353673664493215 51.7970968182672, -0.405545914420316 51.7970968182672,-0.405545914420316 51.8237467815324))'
    farm_csv = os.path.join(working_folder,'temp-nodes_wkt_clean.csv')
    geom_name = 'shape'
    
    product = ProductIO.readProduct(product)
    masked_product = get_masked_product_from_wkt(product, polygons_wkt)
    ProductIO.writeProduct(masked_product, target, 'BEAM-DIMAP')  
    
    
    