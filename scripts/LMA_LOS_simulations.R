#!/usr/bin/env Rscript

# CREATED: P. Altube Vazquez - Jul 2022
# MODIFIED; P. Altube Vazquez - sep 2022
# DESCRIPTION: For the input LMA sites: (1) calculates altitude (from DEM) of 
# locations given in "LMA_coords.txt" and adds it to data file "LMA_data.txt", 
# (2) simulates and plots individual LMA visibility maps.

# SETTINGS ####################################################################

# LMA sites to process (write "all" for processing all sites in coords file)
lma_ID <- seq(57, 60)
# lma_ID <- "all"

# Work directory
path_wrk <- "/Users/patriciaaltube/Desktop/LMA_LOS_simulations"

###############################################################################
# LOAD DEFAULT SETTINGS AND FUNCTIONS #########################################

path_scr <- paste0(path_wrk, "/scripts")
file_set <- paste0(path_scr, "/LMAsim_sets.R")
file_fun <- paste0(path_scr, "/LMAsim_funs.R")

source(file_set, chdir = TRUE)
source(file_fun, chdir = TRUE)

# LOAD INPUT DATA #############################################################

# LMA site coodinates
file_lma <- paste(path_dat, fn_lma_d, sep="/")
file_lma_coords <- paste(path_dat, fn_lma_c, sep="/")

if (!file.exists(file_lma)){
  data_lma <- data.frame(matrix(ncol = 5, nrow = 0))
  colnames(data_lma) <- c("ID", "Nom", "x", "y", "Alt_ETRS")
}else{
  data_lma <- read.table(file_lma, header=TRUE)
}

coords_lma <- read.table(file_lma_coords, header=TRUE)

# DEM and SHP files 
file_dem_alt <- paste(path_dem, fn_dem_alt, sep="/")
file_dem_sim <- paste(path_dem, fn_dem_sim, sep="/")
file_shp_com <- paste(path_shp, fn_shp_com, sep="/")

# DEM data
r_dem_alt <- raster(file_dem_alt)
r_dem <- raster(file_dem_sim)
r_dem[r_dem<0] <- 0

# FIND SITE ALTITUDE FROM DEM #################################################

if (lma_ID=="all"){lma_ID<-coords_lma$ID} else {lma_ID<-as.character(lma_ID)}

# IDs to be processed (not already in data file)
id_alt <- lma_ID[which(!lma_ID %in% data_lma$ID)]

# Handle missing coordinates
id_NA <- id_alt[which(!id_alt %in% coords_lma$ID)]
if (length(id_NA)!=0){
  cat("WARNING: error processing ID(s):", id_NA, 
      "\nInput data not found")
  id_alt <- id_alt[!id_alt %in% id_NA]
}

# Find altitude
coords_lma <- coords_lma[coords_lma$ID %in% id_alt, ]
coords_lma$Alt_ETRS <- extract(r_dem_alt, 
                               cbind(coords_lma$x, coords_lma$y),
                               cellnumbers=FALSE)
coords_lma$Alt_ETRS <- as.numeric(sprintf(coords_lma$Alt_ETRS,fmt = "%.2f"))

# Write to data file
data_lma <- rbind(data_lma, coords_lma)
write.table(data_lma, file_lma, quote = F,
            col.names = T, row.names = F)

# SIMULATE LOS MAPS ###########################################################

id_sim <- lma_ID[!lma_ID %in% id_NA]

# Span and resolution of polar grid
az_span <- seq(0, 360-az_stp, az_stp)
r_span <- seq(r_stp, r_max, r_stp)

# Create output paths if do not exist
if (!file.exists(path_tif)){dir.create(path_tif, recursive=T)}
if (!file.exists(path_plt)){dir.create(path_plt, recursive=T)}

for (id in id_sim){

  coords <- data_lma[data_lma$ID==id, ]
  cat("Processing ID", id, as.character(coords$Nom), "...\n")

  # Grid of LOS (minimum height of sight at each point)
  gr_LOS <- LOS_grid_sim(rast_dem=r_dem, x0=coords$x, y0=coords$y, 
                     h0=coords$Alt_ETRS, az_span=az_span, r_span=r_span)
  # Generate raster
  r_LOS <- make_raster(x=gr_LOS$x, y=gr_LOS$y, z=gr_LOS$h_min,
                        xlims=xlims, ylims=ylims, res=res, proj=myproj)

  # Write output raster
  fr_out <- paste(path_tif, paste0("LOS_lma_", id, ".tif"), sep="/")
  writeRaster(r_LOS, filename=fr_out, format="GTiff", overwrite=TRUE)
  
  # PLOTTING
  id_lab <- paste0("#", id)
  leg_tit <- "Line-Of-Sight height [masl]"
  pl_tit <- paste("Mapa de visibilitat LMA:", id_lab, coords$Nom)
  
  # Write output figure
  pl_out <- paste(path_plt, paste0("LOS_lma_", id, ".png"), sep="/")
  plot_hmin(file_ou=pl_out, rast=r_LOS, 
            rast_dem=r_dem, shpfile=file_shp_com,
            point_utm=subset(coords, select=c("x", "y")), 
            rast_brks=h_brks, rast_colsc=h_colsc_alpha,
            dem_brks=topo_brks, dem_colsc=topo_colsc,
            xlims=xlims, ylims=ylims, 
            pl_tit=pl_tit, leg_tit=leg_tit, 
            point_labs=id_lab, sea_col='white')
  

}