#!/usr/bin/env Rscript

# CREATED: P. Altube Vazquez - May 2022
# MODIFIED; P. Altube Vazquez - Sep 2022
# DESCRIPTION: Settings for building individual LMA visibility (LOS) maps.

## USER SETTINGS ############################################################

path_dat <- paste(path_wrk, "DATA", sep="/")
path_shp <- paste(path_dat, "SHP", sep="/")
path_dem <- paste(path_dat, "DEM", sep="/")

path_plt <- paste(path_wrk, "FIG", sep="/")
path_tif <- paste(path_wrk, "TIF", sep="/")

# Files with LMA site coordinates
fn_lma_d <- "LMA_data.txt"
fn_lma_c <- "LMA_coords.txt"

# DEM and SHP files
fn_dem_alt <- "mde15.tif" # DEM for altitude estimation
fn_dem_sim <- "mde100.img" # DEM for simulations
fn_shp_com <- "comarca.shp"

# Modelling settings
r_max <- 225E3 # range max
r_stp <- 500 # range step
az_stp <- 1 #azimuth step

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

