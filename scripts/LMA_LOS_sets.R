#!/usr/bin/env Rscript

# CREATED: P. Altube - May 2022
# MODIFIED; P. Altube - Oct 2022
# DESCRIPTION: Settings for building individual LMA visibility (LOS) maps.

## MAIN SETTINGS ##############################################################

# Modelling settings for INDIVIDUAL SIMULATIONS
r_max <- 150E3 # Maximum range of the sensors
r_stp <- 500 # range step
az_stp <- 1 #azimuth step

# List of LMA station combinations in the composites
cmp_lst <- list("16a"=c("3", "37b", "6b", "11", "66", "18", "16", "22",
                        "23", "28", "30", "27", "20", "15", "34", "67"), 
                "16b"=c("65", "12b", "6b", "10", "66", "18", "16", "54",
                        "23", "26", "31", "27", "55", "60", "57", "1"),
                "16c"=c("65", "13b", "6b", "11", "66", "18", "21", "35",
                        "68", "28", "31", "24", "20", "52", "2", "1"), 
                "23a"=c("65", "37b", "74", "11", "66", "18", "16", "22",
                        "23", "28", "30", "58", "45", "52", "70", "60",
                        "57", "1", "33", "80", "71", "47", "13b"),
                "23b1"=c("3", "12b", "74", "11", "66", "18", "16", "35",
                         "23", "26", "31", "58", "24", "52", "20", "15",
                         "57", "81", "2", "78", "73", "47", "13"),
                "23b2"=c("3", "12b", "74", "11", "66", "18", "16", "35",
                         "23", "26", "31", "58", "75", "52", "20", "15",
                         "57", "81", "2", "78", "73", "47", "13"),
                "23b3"=c("3", "12b", "74", "11", "66", "18", "16", "35",
                         "23", "26", "31", "58", "76", "52", "20", "15",
                         "57", "81", "2", "78", "73", "47","13"))

## OTHER SETTINGS #############################################################

path_dat <- paste0(path_wrk, "DATA/")
path_shp <- paste0(path_dat, "SHP/")
path_shp_cat <- paste0(path_dat, "CONTORN/")
path_dem <- paste0(path_dat, "DEM/")

# Output paths for individual simulations
path_plt <- paste0(path_wrk, "INDV_PNG/")
path_tif <- paste0(path_wrk, "INDV_TIF/")
path_log <- paste0(path_wrk, "CMP_LOG/")

# Output paths for composites
path_plt_c <- paste0(path_wrk, "CMP_PNG/")
path_tif_c <- paste0(path_wrk, "CMP_TIF/")

# Files with LMA site coordinates
fn_lma_d <- "LMA_data.txt"
fn_lma_c <- "LMA_coords.txt"

# DEM and SHP files
fn_dem_alt <- "mde15.tif" # DEM for altitude estimation
fn_dem_sim <- "mde100.img" # DEM for simulations
fn_shp_com <- "comarca.shp"
fn_shp_cat <- "contorn_catalunya.shp"

# Raster settings
xlims <- c(257980, 535080)
ylims <- c(4484920, 4752020)
res <- c(500, 500)
myproj <- "+proj=utm +zone=31 ellps=WGS84"

# Colorbar for topography
topo_colsc <- rev(c('black', paste0('grey', seq(20, 80, 10)), 'grey92', 'white'))
topo_brks <- c(-250, 0, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 3500)

# Colorbar for height
h_colsc <- rev(hcl.colors(12, "spectral"))
h_colsc[13] <- h_colsc[1]
h_colsc[14] <- '#1a1a1a'
h_colsc[1] <- '#ffffff'
h_colsc_alpha <- adjustcolor(h_colsc, alpha.f=0.5)
h_brks <- c(0, seq(2000, 14000, 1000), 16000)

# Colorbar for number of stations in COMPOSITE plots
n_colsc <- c("lightblue1", "cadetblue3", "deepskyblue3", 
             "lemonchiffon", "lightgoldenrod1", "goldenrod1", 
             "tan1","darkorange1", "orangered", "red3",
             "orchid4", "#1a1a1a")
n_colsc_alpha <- adjustcolor(n_colsc, alpha.f=0.8)
n_brks <- seq(0, 24, 2)

# Total CAT area (contorn)
a_max <- 32100.83

###############################################################################
