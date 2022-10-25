#!/usr/bin/env Rscript

# CREATED: P. Altube - Jul 2022
# MODIFIED; P. Altube - Oct 2022
# DESCRIPTION: Creates a composite map of the number of LMA stations with 
# visibility above the given minimum height (h_ref) at each point, from the 
# collection of LMA stations indicated by the user.
#
# GENERAL SETTINGS FILE: /path_work/scripts/LMA_sim_sets.R

# SETTINGS ####################################################################

# Composites to process (write "all" for processing all composites listed 
# in settings file)
# cmp_names <- "all"
cmp_names <- c("16a", "16b")

# Reference heights above which visibility is desired [m]
heights_ref <- c(4000, 7000)

# Work directory
path_wrk <- "/home/usr/LMA_LOS_simulations/"

###############################################################################
# LOAD DEFAULT SETTINGS AND FUNCTIONS 

path_scr <- paste0(path_wrk, "scripts/")

file_set <- paste0(path_scr, "LMA_LOS_sets.R")
file_fun <- paste0(path_scr, "LMA_LOS_funs.R")

source(file_set, chdir = TRUE)
source(file_fun, chdir = TRUE)

options(warn=-1)

###############################################################################

# DEM file
file_dem <- paste0(path_dem, fn_dem_sim)
try(r_dem <- raster(file_dem), silent=TRUE)
r_dem[r_dem<=0] <- 0

# Shapefile
file_shp_com <- paste0(path_shp, fn_shp_com)

# LMA site coodinates
file_lma <- paste0(path_dat, fn_lma_d)
data_lma_all <- read.table(file_lma, header=TRUE)

# Create output paths if do not exist
if (!file.exists(path_tif_c)){dir.create(path_tif_c, recursive=T)}
if (!file.exists(path_plt_c)){dir.create(path_plt_c, recursive=T)}
if (!file.exists(path_log)){dir.create(path_log, recursive=T)}

# Loop for all selected composites
if (cmp_names=="all"){
  cmp_names <- names(cmp_lst)
}

for (cmp_name in cmp_names){
  
  print(paste("Creating composite", cmp_name, "..."))
  cmp_IDs <- cmp_lst[[cmp_name]]
  
  # LMA location data
  data_lma <- data_lma_all[data_lma_all$ID %in% cmp_IDs, ]
  
  # Site labels for plot
  lma_labs <- paste0("#", data_lma$ID)
  lma_locs <- subset(data_lma, select=c("x", "y"))
  
  # Loop for all selected minimum heights
  for (h_ref in heights_ref){
    
    # Loop for all LMA stations in the composite
    for (lma in cmp_IDs){
      
      # Load TIF file/raster of the LMA station
      f_lma <- paste0(path_tif, paste0("LOS_lma_", lma, ".tif"))
      r_lma <- raster(f_lma)
      
      # Check visibility below ref. height.
      r_tmp <- r_lma
      r_tmp[r_tmp<=h_ref] <- 1
      r_tmp[(is.na(r_tmp)) | (r_tmp>h_ref)] <- 0
      
      # Counter for the num. of stations with visibility above h_ref
      if (!exists("lma_num")){
        lma_num <- r_tmp
      }else{
        # Update counter
        lma_num <- lma_num + r_tmp
      }
      
    }
    
    # Output filename for TIF and PNG
    fname_ou <- paste0("NUM_lma_H", h_ref, "m_R", r_max/1000, "km_", cmp_name)
    
    # Write output raster
    fr_out <- paste0(path_tif_c, paste0(fname_ou, ".tif"))
    writeRaster(lma_num, filename=fr_out, format="GTiff", overwrite=TRUE)
    
    # Crop raster to CAT area only
    fr_out_cr <- paste0(path_tif_c, paste0(fname_ou, "_crop.tif"))
    file_shp_cat <- paste0(path_shp_cat, fn_shp_cat)
    comm <- paste("gdalwarp -cutline", file_shp_cat, 
                  "-crop_to_cutline", fr_out, fr_out_cr)
    system(comm, ignore.stdout = TRUE, ignore.stderr = TRUE)
    lma_num_cr <- raster(fr_out_cr)
    
    # Count number of occurrences and calculate area
    freq_df <- area_by_num(lma_num)
    freq_df_cr <- area_by_num(lma_num_cr)
    
    # PLOTTING
    # Title
    plt_tit <- paste0("Num. of LMA contributors above h=", h_ref, "masl\nN_tot=",
                      length(cmp_IDs))
    
    # Output figure-files
    pl_out <- paste0(path_plt_c, paste0(fname_ou, ".png"))
    pl_out_cr <- paste0(path_plt_c, paste0(fname_ou, "_crop.png"))
    
    # Map covering whole raster area
    plot_hmin(file_ou=pl_out, rast=lma_num, rast_dem=r_dem,
              shpfile=file_shp_com, shp_over=T,
              point_utm=lma_locs, point_labs=lma_labs,
              rast_brks=n_brks, rast_colsc=n_colsc_alpha,
              dem_brks=topo_brks, dem_colsc=topo_colsc,
              xlims=xlims, ylims=ylims, pl_tit=plt_tit,
              leg_tit="", sea_col='white')
    
    # Cropped map covering only Catalonia area
    plot_hmin(file_ou=pl_out_cr, rast=lma_num_cr, rast_dem=r_dem,
              shpfile=file_shp_com, shp_over=T,
              point_utm=lma_locs, point_labs=lma_labs,
              rast_brks=n_brks, rast_colsc=n_colsc_alpha,
              dem_brks=topo_brks, dem_colsc=topo_colsc,
              xlims=xlims, ylims=ylims, pl_tit=plt_tit,
              leg_tit="", sea_col='white')
    
    # LOG FILE WRITING
    lines_ini <- c(paste("#", cmp_name), paste("\n#", fname_ou))
    
    # Log with the list of stations making up the composite
    log1_out <- paste0(path_log, paste0(fname_ou, "_STATIONS.txt"))
    write_log(data_lma, log1_out, lines= c(lines_ini, 
          "\n# List of LMA stations in the composite:\n\n"))
   
    # Log with the area coverage results for the whole raster area
    log2_out <- paste0(path_log, paste0(fname_ou, "_AREAS_TOT.txt"))
    write_log(freq_df, log2_out, lines= c(lines_ini, 
          "\n# How much area [km^2] covered by how many sensors",
          "\n# Whole raster coverage\n\n"))
    
    # Log with the area coverage results for Catalonia area
    log3_out <- paste0(path_log, paste0(fname_ou, "_AREAS_CAT.txt"))
    write_log(freq_df_cr, log3_out, lines= c(lines_ini, 
          "\n# How much area [km^2] covered by how many sensors",
          "\n# CAT area coverage\n\n"))

    rm(lma_num)
    
  }
  
}