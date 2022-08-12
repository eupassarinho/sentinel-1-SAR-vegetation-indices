# Sampling pixels in SNAP (ESA) processed images

## Code wrote and devoted to sampling raster stacks, exemplifying with Sentinel-1
## IW GRD scenes. The code uses ReadDIM package function to read files
## originated in ESA (European Space Agency) SNAP (Sentinel Application Platform) 
## Software.

## The sampling is performed using raster::extract (package::function)
## in the pixel of image within the point is located, and also in different buffers
## around the point.

## The code brings also a way to automatically gather the sampled data
## of different buffer configurations into a single tibble (a data.frame object)

# Coder: Erli Pinto dos Santos
#        Agronomist Engineer
#        Ph.D. student in Agricultural Engineer
# E-mail me at: erlispinto@outlook.com or
#               erli.santos@ufv.br

# Last update: October 03, 2021

# Needed packages ---------------------------------------------------------
# Raster manipulation
#library(sp)       # Classes and methods for spatial data
#library(raster)   # For raster manipulating
library(terra)
library(rgdal)    # Geospatial library
#library(ReadDIM)  # To read ".dim" files from ESA SNAP software

# Data wrangling and visualization
library(dplyr)    # For data wrangling
library(tidyr)    # For data organization
library(tibble)   # A enhanced data.frame
library(ggplot2)  # For awesome charts!
library(readxl)   # Excel sheet handling
library(writexl)  # To write ".xlsx" sheets
library(glue)
library(lubridate)

# Optimizating
library(doParallel)

memory.limit(size = 99999999999)
n_Core <- detectCores()-2
cl <- makePSOCKcluster(n_Core)
registerDoParallel(cl)

# Importing SNAP Processed scenes -----------------------------------------
# Scenes from 2017 --------------------------------------------------------
Scenes_2017 <- list.files(path = "./Processed_Scenes_2017", pattern = ".data")

S1_Jul_2017 <- rast(paste("./Processed_Scenes_2017/", Scenes_2017[1],"/", sep = "",
                          list.files(paste("./Processed_Scenes_2017/", Scenes_2017[1], sep = ""),
                                     pattern = ".img")))

S1_Nov_2017_1 <- rast(paste("./Processed_Scenes_2017/", Scenes_2017[4],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2017/", Scenes_2017[4], sep = ""),
                                       pattern = ".img")))
S1_Nov_2017_2 <- rast(paste("./Processed_Scenes_2017/", Scenes_2017[6],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2017/", Scenes_2017[6], sep = ""),
                                       pattern = ".img")))
S1_Nov_2017_3 <- rast(paste("./Processed_Scenes_2017/", Scenes_2017[7],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2017/", Scenes_2017[7], sep = ""),
                                       pattern = ".img")))

# Scenes from 2018 --------------------------------------------------------
Scenes_2018 <- list.files(path = "./Processed_Scenes_2018", pattern = ".data")

S1_Jul_2018 <- rast(paste("./Processed_Scenes_2018/", Scenes_2018[2],"/", sep = "",
                          list.files(paste("./Processed_Scenes_2018/", Scenes_2018[2], sep = ""),
                                     pattern = ".img")))

S1_Nov_2018_1 <- rast(paste("./Processed_Scenes_2018/", Scenes_2018[7],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2018/", Scenes_2018[7], sep = ""),
                                       pattern = ".img")))
S1_Nov_2018_2 <- rast(paste("./Processed_Scenes_2018/", Scenes_2018[3],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2018/", Scenes_2018[3], sep = ""),
                                       pattern = ".img")))
S1_Nov_2018_3 <- rast(paste("./Processed_Scenes_2018/", Scenes_2018[9],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2018/", Scenes_2018[9], sep = ""),
                                       pattern = ".img")))

# Scenes from 2019 --------------------------------------------------------
Scenes_2019 <- list.files(path = "./Processed_Scenes_2019", pattern = ".data")

S1_Jul_2019 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[2],"/", sep = "",
                          list.files(paste("./Processed_Scenes_2019/", Scenes_2019[2], sep = ""),
                                     pattern = ".img")))

S1_Nov_2019_1 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[3],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2019/", Scenes_2019[3], sep = ""),
                                       pattern = ".img")))
S1_Nov_2019_2 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[4],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2019/", Scenes_2019[4], sep = ""),
                                       pattern = ".img")))
S1_Nov_2019_3 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[5],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2019/", Scenes_2019[5], sep = ""),
                                       pattern = ".img")))
S1_Nov_2019_4 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[6],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2019/", Scenes_2019[6], sep = ""),
                                       pattern = ".img")))
S1_Nov_2019_5 <- rast(paste("./Processed_Scenes_2019/", Scenes_2019[7],"/", sep = "",
                            list.files(paste("./Processed_Scenes_2019/", Scenes_2019[7], sep = ""),
                                       pattern = ".img")))

# Importing vectors -------------------------------------------------------
files <- list.files("./Vetores/", pattern = ".shp")
# Reading points from both months, July and November
{points_Jul <- vect(paste("./Vetores/",files[9],sep=""));
  points_Nov <- vect(paste("./Vetores/",files[10],sep=""))}
# Reading buffers from July
{buffer_Jul_20 <- vect(paste("./Vetores/", files[2], sep=""));
  buffer_Jul_40 <- vect(paste("./Vetores/", files[3],sep=""));
  buffer_Jul_80 <- vect(paste("./Vetores/", files[4],sep=""));
  buffer_Jul_160 <- vect(paste("./Vetores/",files[1], sep=""))}
# Reading buffers from November
{buffer_Nov_20 <- vect(paste("./Vetores/", files[6], sep=""));
  buffer_Nov_40 <- vect(paste("./Vetores/", files[7], sep=""));
  buffer_Nov_80 <- vect(paste("./Vetores/", files[8], sep=""));
  buffer_Nov_160 <- vect(paste("./Vetores/",files[5], sep=""))}

# Sampling rasters --------------------------------------------------------
# July --------------------------------------------------------------------

Samples_Jul_2017 <- bind_cols(
  # Points
  {terra::extract(S1_Jul_2017, points_Jul, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2017"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2017")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2017")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2017")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2017")),
    terra::extract(S1_Jul_2017, buffer_Jul_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2017")))})

Samples_Jul_2018 <- bind_cols(
  # Points
  {terra::extract(S1_Jul_2018, points_Jul, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2018"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2018")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2018")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2018")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2018")),
    terra::extract(S1_Jul_2018, buffer_Jul_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2018")))})

Samples_Jul_2019 <- bind_cols(
  # Points
  {terra::extract(S1_Jul_2019, points_Jul, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Jul_2019, buffer_Jul_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Jul <- bind_cols(points_Jul %>% as.data.frame(),
                         Samples_Jul_2017, Samples_Jul_2018,
                         Samples_Jul_2019)
#remove(Samples_Jul_2017, Samples_Jul_2018, Samples_Jul_2019)
Samples_Jul <- Samples_Jul %>% select(-contains("..")) %>%
  filter(!Sigma0_VH_pixel_2017 == 0)
  
# November ----------------------------------------------------------------
##############
Samples_Nov_2017_1 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2017_1, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2017"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2017")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2017")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2017")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2017")),
    terra::extract(S1_Nov_2017_1, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2017")))})

Samples_Nov_2017_2 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2017_2, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2017"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2017")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2017")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2017")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2017")),
    terra::extract(S1_Nov_2017_2, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2017")))})

Samples_Nov_2017_3 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2017_3, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2017"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2017")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2017")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2017")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2017")),
    terra::extract(S1_Nov_2017_3, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2017")))})

Samples_Nov_2017_1 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2017_1)
Samples_Nov_2017_2 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2017_2)
Samples_Nov_2017_3 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2017_3)

Samples_Nov_2017 <- bind_rows(Samples_Nov_2017_1 %>% select(-contains("RVIm.")),
                              Samples_Nov_2017_2 %>% select(-contains("RVIm.")),
                              Samples_Nov_2017_3 %>% select(-contains("RVIm.")))
Samples_Nov_2017 <- Samples_Nov_2017 %>% select(-contains("ID."))

Samples_Nov_2017 <- Samples_Nov_2017 %>% filter(!DPSVI_pixel_2017 == 0)
Samples_Nov_2017 <- Samples_Nov_2017 %>% arrange(Perfil, desc())

##############
Samples_Nov_2018_1 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2018_1, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2018"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2018")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2018")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2018")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2018")),
    terra::extract(S1_Nov_2018_1, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2018")))})

Samples_Nov_2018_2 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2018_2, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2018"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2018")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2018")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2018")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2018")),
    terra::extract(S1_Nov_2018_2, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2018")))})

Samples_Nov_2018_3 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2018_3, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2018"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2018")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2018")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2018")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2018")),
    terra::extract(S1_Nov_2018_3, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2018")))})

Samples_Nov_2018_1 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2018_1)
Samples_Nov_2018_2 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2018_2)
Samples_Nov_2018_3 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2018_3)

Samples_Nov_2018 <- bind_rows(Samples_Nov_2018_1 %>% select(-contains("RVIm.")),
                              Samples_Nov_2018_2 %>% select(-contains("RVIm.")),
                              Samples_Nov_2018_3 %>% select(-contains("RVIm."))) %>%
  select(-contains("ID."))

Samples_Nov_2018 <- Samples_Nov_2018 %>% filter(!DPSVI_pixel_2018 == 0)
Samples_Nov_2018 <- Samples_Nov_2018 %>% arrange(Perfil, desc())

##############
Samples_Nov_2019_1 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2019_1, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Nov_2019_1, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Nov_2019_2 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2019_2, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Nov_2019_2, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Nov_2019_3 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2019_3, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Nov_2019_3, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Nov_2019_4 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2019_4, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Nov_2019_4, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Nov_2019_5 <- bind_cols(
  # Points
  {terra::extract(S1_Nov_2019_5, points_Nov, method = "simple") %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB,
                            RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_pixel_2019"))},
  # Buffer 20 m
  {bind_cols(
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_mean_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sd_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_sum_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_min_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_max_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_20, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_20m_var_2019")))},
  # Buffer 40 m
  {bind_cols(
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_mean_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sd_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_sum_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_min_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_max_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_40, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_40m_var_2019")))},
  # Buffer 80 m
  {bind_cols(
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_mean_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sd_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_sum_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_min_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_max_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_80, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_80m_var_2019")))},
  # Buffer 160 m
  {bind_cols(
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = mean, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_mean_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = sd, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sd_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = sum, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_sum_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = min, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_min_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = max, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_max_2019")),
    terra::extract(S1_Nov_2019_5, buffer_Nov_160, fun = var, touches = TRUE) %>%
      rename_at(dplyr::vars(CR_VVbyVH_dB, DPSVI, DPSVIm, Pol_dB, RVIm_dB, Sigma0_VH, Sigma0_VV),
                function(x) paste0(x,"_160m_var_2019")))})

Samples_Nov_2019_1 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2019_1)
Samples_Nov_2019_2 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2019_2)
Samples_Nov_2019_3 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2019_3)
Samples_Nov_2019_4 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2019_4)
Samples_Nov_2019_5 <- bind_cols(points_Nov %>% as.data.frame(), Samples_Nov_2019_5)

Samples_Nov_2019 <- bind_rows(Samples_Nov_2019_1 %>% select(-contains("RVIm.")),
                              Samples_Nov_2019_2 %>% select(-contains("RVIm.")),
                              Samples_Nov_2019_3 %>% select(-contains("RVIm.")),
                              Samples_Nov_2019_4 %>% select(-contains("RVIm.")),
                              Samples_Nov_2019_5 %>% select(-contains("RVIm."))) %>%
  select(-contains("ID."))

Samples_Nov_2019 <- Samples_Nov_2019 %>% filter(!DPSVI_pixel_2019 == 0)
Samples_Nov_2019 <- Samples_Nov_2019 %>% arrange(Perfil, desc())

# Collecting samples in raster stack objects ------------------------------
# Using extract function, from raster package, to perform image
# sampling data of interest points

Sampling <- function(RasterStack,                # No default
                     SpatialDf,                  # No default
                     buffer_ = c(0, 20, 30, 50), # A numeric vector as default
                     imgDate = "2017-07-06",     # A character object as default
                     funct = mean,               # A function to apply in buffers
                     funct_name = "mean"         # A function name to cols
                     ) {   
  # Variable to receive the buffer vector:
  buffers <- buffer_            
  # List that will receive data.frames containing samplings of each buffer setting,
  # being a data.frame for each buffer:
  List_ = list()                
  
  for (i in 1:length(buffers)) {
    List_[[i]] <- 
      raster::extract(
        RasterStack,        # Raster Stack containing interests bands
        SpatialDf,          # SpatialPointsDataFrame
        df = TRUE,          # Generate an ID column
        buffer = buffers[i],# Buffer radius (in meters) around each coordinate point
        fun = funct,        # Function to apply to pixels from buffer
        method = "simple",  # Return value for the cell that a point falls
        sp = TRUE,          # Update SpatialPointsDataFrame with samples collected
        # Important to known the spatial location of points, buffers and image pixels
        na.rm = TRUE,
        exact = TRUE,      # Return the value of partly covered cell
        )@data %>% # "@data" to get only the data.frame from Spatial Object
      tibble() %>%          # Collecting "@data" to a tibble
      #filter(Sigma0_VH != 0)  %>% # Only for radar Sentinel-1 data
      # Renaming sampled variables to include a buffer indication (as suffix at var name)
      rename_at(dplyr::vars(-c(Perfil, ID, DATA, AREA, `USO DO SOLO`,
                               CLS, Profundidade, `Profundidade (m)`, `Espessura (cm)`,
                               `Areia Fina (kg/kg)`, `Areia Grossa (kg/kg)`, `Argila (kg/kg)`,
                               `Densidade (Mg m-3)`, `Silte (kg/kg)`, `MO (dag/kg)`,
                               `SOC (dag/kg)`, `Estoque SOC (Mg/ha)`, long, lat)),
                function(x) paste0(funct_name,"_",x,"_",buffers[i],"_m")) 
  }
  
  # Merging tibbles inside the list into a single tibble
  ## Also a character variable with the image date is created by "mutate"
  joined = tibble(Reduce(function(...) merge(..., all = TRUE), List_)) %>% 
    mutate(DateOfImage = imgDate)
  
  return(joined)
}

##########################################
df <- tibble(V = c(1,2,3,4,5),
             e = seq(from = 1, to = 2, by = 0.25))

df1 <- tibble(a = c(3,5,7,8,10),
             b = seq(from = 2, to = 4, by = 0.5),
             e = seq(from = 1, to = 2, by = 0.25))

df2 <- tibble(j = c(5,5,5,5,5),
              b = seq(from = 2, to = 4, by = 0.5),
              e = seq(from = 1, to = 2, by = 0.25))

list_test <- list(df, df1, df2)


Reduce(function(x, y) merge(x, y, all=TRUE), list(df1, df2, df3))

Reduce(function(...) merge(..., all=TRUE), list(df1, df2, df3))

df_n <- Reduce(function(...) merge(..., all = TRUE), list_test)
               

help(merge)

Teste <- function(data) {
  binded <- tibble()
  for (i in 1:length(data)) {
    binded = bind_cols(data[])
  }
  return(binded)
}

joined <- Teste(data = list_test)


##########################################

## Applying function to get samples:
### mean, max, min, range, prod, sum, any, all
Get_Samples <- function(rasterstack, spatialdf,
                        imageDate = "2017-07-06",
                        Buffer = c(0, 20, 40, 80, 160)) {
  Lista <- list()
  
  Lista[1] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = mean, funct_name = "mean")
  Lista[2] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = max, funct_name = "max")
  Lista[3] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = min, funct_name = "min")
  Lista[4] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = range, funct_name = "range")
  Lista[5] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = prod, funct_name = "prod")
  Lista[6] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = sum, funct_name = "sum")
  Lista[7] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = sd, funct_name = "sd")
  Lista[8] = Sampling(RasterStack = rasterstack, SpatialDf = spatialdf,
                     buffer_ = Buffer, imgDate = imageDate,
                     funct = var, funct_name = "var")

  return(Lista)
}

# Sampling the July Sentinel-1 scenes

df_Jul_2017 <- list({Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = mean, funct_name = "mean")},
                    {Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = max, funct_name = "max")},
                    {Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = min, funct_name = "min")},
                    {Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = prod, funct_name = "prod")},
                    {Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = sum, funct_name = "sum")},
                    {Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-07-06",
                              funct = sd, funct_name = "sd")})

df_Jul_2018 <- list({Sampling(RasterStack = S1_Jul_2017, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = mean, funct_name = "mean")},
                    {Sampling(RasterStack = S1_Jul_2018, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = max, funct_name = "max")},
                    {Sampling(RasterStack = S1_Jul_2018, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = min, funct_name = "min")},
                    {Sampling(RasterStack = S1_Jul_2018, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = prod, funct_name = "prod")},
                    {Sampling(RasterStack = S1_Jul_2018, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = sum, funct_name = "sum")},
                    {Sampling(RasterStack = S1_Jul_2018, SpatialDf = SL_Jul_2017_spatial,
                              buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-07-01",
                              funct = sd, funct_name = "sd")})

df_Jul_2019 <- list({Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = mean, funct_name = "mean")},
                    {Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = max, funct_name = "max")},
                    {Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = min, funct_name = "min")},
                    {Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = prod, funct_name = "prod")},
                    {Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = sum, funct_name = "sum")},
                    {Sampling(RasterStack = S1_Jul_2019, SpatialDf = SL_Jul_2017_spatial,
                             buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-07-08",
                             funct = sd, funct_name = "sd")})

Samples_Jul <- list(df_Jul_2017, df_Jul_2018, df_Jul_2019)
save(Samples_Jul, file = "SOC_SAR_Samples_Jul.RData")

# Sampling the November 2017 Sentinel-1 scenes
# S1_Nov_2017_1
# S1_Nov_2017_2
# S1_Nov_2017_3
df_Nov_2017_1 <- list({Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2017_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = sd, funct_name = "sd")})

df_Nov_2017_2 <- list({Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2017_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-03",
                                funct = sd, funct_name = "sd")})

df_Nov_2017_3 <- list({Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2017_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2017-11-08",
                                funct = sd, funct_name = "sd")})

Samples_Nov_2017 <- list(df_Nov_2017_1, df_Nov_2017_2, df_Nov_2017_3)
save(Samples_Nov_2017, file = "SOC_SAR_Samples_Nov_2017.RData")

# Sampling the November 2018 Sentinel-1 scenes
# S1_Nov_2018_1
# S1_Nov_2018_2
# S1_Nov_2018_3
df_Nov_2018_1 <- list({Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                                funct = mean, funct_name = "mean")},
                      #{Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                      #          buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                      #          funct = max, funct_name = "max")},
                      #{Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                      #          buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                      #          funct = min, funct_name = "min")},
                      #{Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                      #          buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                      #          funct = prod, funct_name = "prod")},
                      #{Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                      #          buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                      #          funct = sum, funct_name = "sum")},
                      #{Sampling(RasterStack = S1_Nov_2018_1, SpatialDf = SL_Nov_2017_spatial,
                      #          buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-03",
                      #          funct = sd, funct_name = "sd")}
                      )

df_Nov_2018_2 <- list({Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2018_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2018_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = sd, funct_name = "sd")})

df_Nov_2018_3 <- list({Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2018_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2018-11-10",
                                funct = sd, funct_name = "sd")})

Samples_Nov_2018 <- list(df_Nov_2018_1, df_Nov_2018_2, df_Nov_2018_3)
save(Samples_Nov_2018, file = "SOC_SAR_Samples_Nov_2018.RData")

# Sampling the November 2019 Sentinel-1 scenes
# S1_Nov_2019_1
# S1_Nov_2019_2
# S1_Nov_2019_3
# S1_Nov_2019_4
# S1_Nov_2019_5

df_Nov_2019_1 <- list({Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2019_1, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sd, funct_name = "sd")})

df_Nov_2019_2 <- list({Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2019_2, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sd, funct_name = "sd")})

df_Nov_2019_3 <- list({Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2019_3, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sd, funct_name = "sd")})

df_Nov_2019_4 <- list({Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2019_4, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-05",
                                funct = sd, funct_name = "sd")})

df_Nov_2019_5 <- list({Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = mean, funct_name = "mean")},
                      {Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = max, funct_name = "max")},
                      {Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = min, funct_name = "min")},
                      {Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = prod, funct_name = "prod")},
                      {Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = sum, funct_name = "sum")},
                      {Sampling(RasterStack = S1_Nov_2019_5, SpatialDf = SL_Nov_2017_spatial,
                                buffer_ = c(0, 20, 40, 80, 160), imgDate = "2019-11-10",
                                funct = sd, funct_name = "sd")})

Samples_Nov_2019 <- list(df_Nov_2019_1,df_Nov_2019_2,df_Nov_2019_3,
                         df_Nov_2019_4,df_Nov_2019_5)
save(Samples_Nov_2019, file = "SOC_SAR_Samples_Nov_2019.RData")

# Visualizing data --------------------------------------------------------

ggplot(SL_Nov_2017)+
  geom_point(aes(`Organic carbon (dag/kg)`, Sigma0_VH_0_m))+
  facet_wrap(~`Depth (meters)`)

# Wrangling and exporting data --------------------------------------------
# Gathering data into a single tibble
SOC_SAR <- bind_rows(SL_Jul_2017, SL_Jul_2018, SL_Nov_2017, SL_Nov_2018)

# Exporting tibble as Excel sheet
write_xlsx(SOC_SAR, "SOC_SAR_Savanna_Bahia.xlsx", col_names = T)

