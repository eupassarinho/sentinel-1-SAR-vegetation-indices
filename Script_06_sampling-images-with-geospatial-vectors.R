# Intro -------------------------------------------------------------------

# Script designed to perform sampling pixels in BEAM-DIMAP images, with
# ".dim" extention, which is the default image format of SeNtinel
# Application Platform from the European Space Agency (SNAP-ESA)

## Script for sampling raster stacks. The code uses ReadDIM package function to
## read SNAP BEAM-DIMAP files.
## The sampling is performed, using terra features, both in the pixel of an
## image (where the sampling point is located) and in different buffers (around
## the sampling point). For the second way, statistical metrics, like average,
## are computed.

## Inputs: BEAM-DIMAP (".dim") image file and 
## Output: Excel file with collected samples.

# Last update: October 03, 2021

# Created on Sun Oct 03, 2021
# Last updated on: Fri Aug 12, 2022

# This code is part of the Erli's Ph.D. thesis

# Author: Erli Pinto dos Santos
# Contact-me on: erlipinto@gmail.com or erli.santos@ufv.br

# Requested packages ------------------------------------------------------

library(terra)    # Fast raster manipulations
library(rgdal)    # Geospatial library
library(ReadDIM)  # To read ".dim" files from ESA SNAP software

# Data wrangling and visualization
library(dplyr)    # For data wrangling
library(tidyr)    # For data organization
library(tibble)   # A enhanced data.frame
library(readxl)   # Excel sheet handling
library(writexl)  # To write ".xlsx" sheets
library(glue)
library(lubridate)# For dealing with date variables

# For optimizating
library(doParallel)

n_Core <- detectCores()-2
cl <- makePSOCKcluster(n_Core)
registerDoParallel(cl)

# Inputs ------------------------------------------------------------------
# Importing SNAP Processed scenes -----------------------------------------

# Listing rasters within a directory --------------------------------------
input_products_path <- "C:/Users/erlis/OneDrive/Área de Trabalho/GRD_Processed"

products_list <- list.files(input_products_path, pattern = ".data")

product_bands <- list.files(paste0(input_products_path, "/", products_list),
                            pattern = ".img")

bands2stack <- rast(paste0(input_products_path, "/", products_list, "/",
                           product_bands))

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
rm(i, radius)

# Sampling ----------------------------------------------------------------

#test_df <- terra::extract(bands2stack, sampling_points, method = "simple", df = TRUE)
#test_df_2 <- bind_cols(terra::as.data.frame(sampling_points), test_df)

if (exists("buffers")) {
  if (length(buffers) >= 1) {
    
    raster2singleSample <- terra::extract(bands2stack, sampling_points,
                                          method = "simple") %>% as_tibble()
    raster2singleSample <- raster2singleSample %>%
      rename_at(vars(dplyr::everything()), function(x) paste0(x,"_pixel"))
    
    raster2samples <- bind_cols(terra::as.data.frame(sampling_points),
                                raster2samples)

  }
} else {
  
  raster2samples <- terra::extract(bands2stack, sampling_points,
                                   method = "simple") %>% as_tibble()
  raster2samples <- raster2samples %>% rename_at(vars(dplyr::everything()),
                                                 function(x) paste0(x,"_pixel"))

  raster2samples <- bind_cols(terra::as.data.frame(sampling_points),
                              raster2samples)

}


# Outputs -----------------------------------------------------------------

