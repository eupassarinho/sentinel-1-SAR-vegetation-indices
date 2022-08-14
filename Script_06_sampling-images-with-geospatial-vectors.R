# Intro -------------------------------------------------------------------

# Script designed to perform sampling pixels in BEAM-DIMAP image
# directories, those with ".data" file extension associated with a ".dim"
# file extension, which is the default image format of SeNtinel Application
# Platform, from the European Space Agency (SNAP-ESA)

## Script for sampling raster stacks. The sampling is performed, using terra
## features, both in the pixel of an image (where the sampling point is
## located) and in different buffers (around the sampling point), which is
## optional. For the second way (sampling in buffers) different buffer radius
## can be set using a vector, and for each buffer setting (one or more),
## statistical metrics (average, standard-deviation, sum, minimum, maximum,
## and variance) are returned.

## Inputs: BEAM-DIMAP (".data") image bands and a Excel file with
## Longitude and Latitude (in this exactly order!) point coordinates;
## Output: Excel file with collected samples.

# Created on Sun Oct 03, 2021
# Last updated on: Sun Aug 14, 2022

# This code is part of the Erli's Ph.D. thesis

# Author: Erli Pinto dos Santos
# Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

# REQUESTED PACKAGES ------------------------------------------------------

library(terra)      # Fast raster manipulation
library(rgdal)      # Geospatial library

# For data wrangling
library(dplyr)      # For data wrangling
library(tidyr)      # For data organization
library(tibble)     # A enhanced data.frame
library(readxl)     # Excel sheet handling
library(writexl)    # To write ".xlsx" sheets
library(lubridate)  # For dealing with date variables

# For optimizating
library(doParallel)

n_Core <- detectCores()-2
cl <- makePSOCKcluster(n_Core)
registerDoParallel(cl)

# INPUTS ------------------------------------------------------------------
# IMPORT SNAP PROCESSED SCENES --------------------------------------------
## Setting directory where BEAM-DIMAP product files and its sub directories
## are located:
input_products_path <- "C:/Users/erlis/Downloads/GRD_Processed"

## Getting a list of BEAM-DIMAP product directories, one for each processed
## image:
products_list <- list.files(input_products_path, pattern = ".data")

## Within directory of each processed image, getting a list of its bands:
product_bands <- list.files(paste0(input_products_path, "/", products_list),
                            pattern = ".img")

## Reading and stacking bands within a BEAM-DIMAP directory as a 
## Formal SpatRaster dataset (from terra package):
bands2stack <- rast(paste0(input_products_path, "/", products_list, "/",
                           product_bands))

## Getting the product name:
product_name <- substr(products_list, start = 0, stop = 96)

# Importing vectors -------------------------------------------------------
## Setting the path where the sampling points are located:
input_points_path <- "C:/Users/erlis/Documents/MEGA/Projeto_de_pesquisa_Doutorado/Database/Solos_Bahia"

df <- read_xlsx(
  paste0(input_points_path, "/05_EstoqueC_Dados_campobruto_dionizio_erli.xlsx"))

# Filtering data frame:
df <- df %>% mutate(SampleMonth = month(DATA)) %>%
  filter(SampleMonth == 7)

# Transforming data frame containing coordinate points to a spatial vector (
# terra SpatVector):

sampling_points <- vect(df,
                        geom = c("LON", "LAT"),
                        crs = "EPSG:4326")         # WGS84 (original from file)

# Reproject SpatVector to match image projection:
sampling_points <- terra::project(sampling_points,
                                  crs(bands2stack))# WGS84/UTM zone 23S

# Removing junkerie
rm(df, input_points_path)

# Creating buffers around points. If you only want to get image samples
# in point locations, just comment the following lines:
radius <- c(20, 40, 80, 160, 320) # radius of each buffer (meters)

points2buffers <- list()

for (i in 1:length(radius)) {
  points2buffers[[i]] <- buffer(sampling_points, radius[i])
}

# Removing junkerie
rm(i)

# SETTING SAMPLES OUTPUT DIRECTORY ----------------------------------------

output_directory <- "C:/Users/erlis/Downloads/GRD_Samples"

# Sampling ----------------------------------------------------------------

if (exists("points2buffers")) {
  
  if (length(points2buffers) >= 1) {
    
    ## Falling pixel sampling:
    raster2singlePixel <- terra::extract(bands2stack, sampling_points,
                                         method = "simple", ID = TRUE) %>% as_tibble()
    raster2singlePixel <- raster2singlePixel %>%
      rename_at(vars(dplyr::everything()), function(x) paste0(x,"_pixel"))

    # Buffer sampling ------------------------------------------------------
    ## Return the MEAN of the pixel values inside a given buffer: 
    n_buffers4mean <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_mean <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = mean, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_mean <- rast2buffer_mean %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_mean_", radius[i], "_m"))
      
      n_buffers4mean[[i]] <- rast2buffer_mean
      
      rm(rast2buffer_mean)
    }
                
    n_buffers4mean <- bind_cols(n_buffers4mean)
    
    ## Return the STANDARD-DEVIATION of the pixel values inside a given buffer: 
    n_buffers4sd <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_sd <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = sd, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_sd <- rast2buffer_sd %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_sd_", radius[i], "_m"))
      
      n_buffers4sd[[i]] <- rast2buffer_sd
      
      rm(rast2buffer_sd)
    }
    
    n_buffers4sd <- bind_cols(n_buffers4sd)
    
    ## Return the MEDIAN of the pixel values inside a given buffer: 
    n_buffers4median <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_median <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = median, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_median <- rast2buffer_median %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_median_", radius[i], "_m"))
      
      n_buffers4median[[i]] <- rast2buffer_median
      
      rm(rast2buffer_median)
    }
    
    n_buffers4median <- bind_cols(n_buffers4median)
    
    ## Return the SUM of the pixel values inside a given buffer: 
    n_buffers4sum <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_sum <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = sum, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_sum <- rast2buffer_sum %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_sum_", radius[i], "_m"))
      
      n_buffers4sum[[i]] <- rast2buffer_sum
      
      rm(rast2buffer_sum)
    }
    
    n_buffers4sum <- bind_cols(n_buffers4sum) 
    
    ## Return the MINIMUM value from pixel values inside a given buffer: 
    n_buffers4min <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_min <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = min, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_min <- rast2buffer_min %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_min_", radius[i], "_m"))
      
      n_buffers4min[[i]] <- rast2buffer_min
      
      rm(rast2buffer_min)
    }
    
    n_buffers4min <- bind_cols(n_buffers4min)  
    
    ## Return the MAXIMUM value from pixel values inside a given buffer: 
    n_buffers4max <- list()

    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_max <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = max, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_max <- rast2buffer_max %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_max_", radius[i], "_m"))
      
      n_buffers4max[[i]] <- rast2buffer_max
      
      rm(rast2buffer_max)
    }
    
    n_buffers4max <- bind_cols(n_buffers4max)  
    
    ## Return the VARIANCE of the pixel values inside a given buffer: 
    n_buffers4var <- list()
    
    for (i in seq(along.with = points2buffers)) {
      
      rast2buffer_var <- terra::extract(
        bands2stack, points2buffers[[i]],
        fun = var, #ID = TRUE,
        method = "simple", touches = TRUE) %>% as_tibble()
      
      rast2buffer_var <- rast2buffer_var %>%
        rename_at(vars(dplyr::everything()),
                  function(x) paste0(x,"_var_", radius[i], "_m"))
      
      n_buffers4var[[i]] <- rast2buffer_var
      
      rm(rast2buffer_var)
    }
    
    n_buffers4var <- bind_cols(n_buffers4var)  
    
    # Gathering collected samples:
    raster2samples <- bind_cols(terra::as.data.frame(sampling_points),
                                raster2singlePixel, n_buffers4mean,
                                n_buffers4median, n_buffers4sd, n_buffers4sum,
                                n_buffers4min, n_buffers4max, n_buffers4var)
    
    rm(raster2singlePixel, n_buffers4mean, n_buffers4sd, n_buffers4sum,
       n_buffers4min, n_buffers4max, n_buffers4var, n_buffers4median)
    
    raster2samples <- raster2samples %>% mutate(Sum = apply(
      raster2samples %>% select(contains("_")), 1, FUN = sum)) %>% 
      filter(Sum != 0) %>% select(-Sum)

  }
} else {
  
  raster2samples <- terra::extract(bands2stack, sampling_points,
                                   method = "simple") %>% as_tibble()
  raster2samples <- raster2samples %>% rename_at(vars(dplyr::everything()),
                                                 function(x) paste0(x,"_pixel"))

  raster2samples <- bind_cols(terra::as.data.frame(sampling_points),
                              raster2samples)
  
  raster2samples <- raster2samples %>% mutate(Sum = apply(
    raster2samples %>% select(contains("_")), 1, FUN = sum)) %>% 
    filter(Sum != 0) %>% select(-Sum)

}


# Outputs -----------------------------------------------------------------

if (!dir.exists(output_directory)){
  print("Creating directory...")
  
  dir.create(output_directory)
  print("Done.")
  
  print("Exporting samples...")
  
  write_xlsx(raster2samples,
             path = paste0(output_directory, "/", product_name,
                           "_samples.xlsx"),
             col_names = TRUE)
  
  print("Export successful!")
  
} else {
  print("Directory already exists!")
  print("Exporting samples...")
  
  write_xlsx(raster2samples,
             path = paste0(output_directory, "/", product_name,
                           "_samples.xlsx"),
             col_names = TRUE)
  
  print("Export successful!")
}

rm(bands2stack, raster2samples, product_bands, product_name)
