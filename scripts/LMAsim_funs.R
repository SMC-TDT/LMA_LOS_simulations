#!/usr/bin/env Rscript

# CREATED: P. Altube Vazquez - May 2022
# MODIFIED; P. Altube Vazquez - Sep 2022
# DESCRIPTION: Calculation and plotting functions for LMA visibility maps.

###############################################################################

library(raster)
library(rgdal)
library(plyr) # grouping & summarising
library(data.table) # table manipulation
library(akima) # interpolation
library(maptools) # shapefile reading

###############################################################################

grid_utm <- function(x0, y0, az_span=seq(0.5, 359.5, 0.5), 
                     r_span=seq(0, 150, 1)){
  
  df <- expand.grid(az=az_span, r=r_span)
  df$x <- x0 + df$r*sin(df$az*pi/180)
  df$y <- y0 + df$r*cos(df$az*pi/180)
  
  return(df)
}

extract_dem_data <- function(grid_df, rast_dem, cols=c("x", "y")){
  
  beam_data <- extract(rast_dem, cbind(grid_df$x, grid_df$y), 
                       cellnumbers=TRUE)
  
  grid_df$hdem <- beam_data[, 2]
  grid_df$cell <- beam_data[, 1]
 
  # Remove cells that fall out of the extent of the DEM raster
  grid_df <- grid_df[!is.na(grid_df$cell),]
  grid_df <- grid_df[!is.na(grid_df$hdem),]
  
  return(grid_df)  
}

latlon2utm <- function(df, proj, cols=c("lat", "lon")){
  
  df <- subset(df, select=cols)
  names(df) <- c("Y", "X")
  coordinates(df) <- ~ X + Y # longitude first
  proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  utm <- as.data.frame(spTransform(df, CRS(myproj)))
  
  return(utm)
}

LOS_grid_sim <- function(rast_dem, x0, y0, h0, az_span, r_span){
  
  # Create grid
  gr <- grid_utm(x0=x0, y0=y0, az_span=az_span, r_span=r_span)
  # sort radial-by-radial
  gr <- gr[order(gr$az, gr$r),]
  
  # DEM cells and data corresponding to beam coordinates
  # takes some time...
  gr <- extract_dem_data(grid_df=gr, rast_dem=rast_dem)
  
  # Effective DEM height (with respect to lma tower height)
  gr$hi <- gr$hdem - h0
  
  # LOS angle based on DEM height
  gr$ai <- atan(gr$hi/gr$r)
  # Maximum cumulative LOS angle along beam
  gr <- ddply(gr, .(az), .fun=transform, a_max=cummax(ai))
  # Minimum LOS height
  gr$h_min <- h0 + gr$r*tan(gr$a_max)
  gr$h_min[gr$a_max<0] <- 0
  
  return(gr)
  
}

make_raster <- function(x, y, z, xlims, ylims, res, proj){
  
  x_grid <- seq(xlims[1], xlims[2], res[1])
  y_grid <- seq(ylims[1], ylims[2], res[2])
  
  intp <- interp(x=x, y=y, z=z, xo=x_grid, yo=y_grid,
                 linear=TRUE, extrap=FALSE)
  intp$z <- apply(t(intp$z), 2, rev)
  
  rast <- raster(intp$z, xmn=min(intp$x), xmx=max(intp$x), 
                 ymn=min(intp$y), ymx=max(intp$y), CRS(proj))
  
  return(rast)
  
}

plot_hmin <- function(file_ou, rast, rast_dem, shpfile, point_utm, 
                      point_labs, rast_brks, rast_colsc, dem_brks, dem_colsc, 
                      xlims, ylims, pl_tit, leg_tit, sea_col='white'){
  
  rast_dem[rast_dem==0] <- NA
  shp <- readShapeLines(shpfile, proj4string = CRS(myproj))
  
  png(width=1500, height=1500, file=file_ou)
  # par(mar=c(5,5,4,3), bty="n")
  plot(rast_dem, breaks=topo_brks, col=topo_colsc,
       xlab="", ylab="", cex.lab=2, main=pl_tit, cex.main=3,
       xlim=c(xlims[1], xlims[2]), ylim=c(ylims[1], ylims[2]),
       xaxt="n", yaxt="n", legend=FALSE, colNA=sea_col)
  plot(shp, bg="transparent", add=T, col="black", width=0.5)
  plot(rast, col=rast_colsc, breaks=rast_brks, legend=FALSE, add=TRUE)
  points(point_utm$x, point_utm$y, pch=16, col="black", cex=2)
  text(x=point_utm$x, y=point_utm$y+5000, labels=point_labs, cex=2.5,col="black")
  plot(rast, col=rast_colsc, breaks=rast_brks, horizontal=TRUE, legend.mar=12,
       legend.shrink=0.7, legend.only=T, legend.width=1.3,
       legend.args=list(text=leg_tit, side=1, cex=2, line=-3, las=1),
       axis.args=list(cex.axis=1.5))
  dev.off()
  
}
###############################################################################
