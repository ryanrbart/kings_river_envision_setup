# Gridmet import and processsing

# All data is reprojected (if necessary) to lat/long

source("R/0_utilities.R")

# ---------------------------------------------------------------------
# Define projections

proj_longlat <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
proj_prism <- "+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"

# ---------------------------------------------------------------------
# Import SSIRWMG Boundary

kings_border <- st_read(dsn = "data/gis/", layer="kings")
kings_border <- st_transform(kings_border, crs = proj_longlat)

# kings_border_sp <- as(st_geometry(kings_border), "Spatial")  # Change from sf to sp object since raster::crop won't work with extent of sf object
# e <- extent(kings_border_sp)
# # Use ss_border for graphics, e for cropping/masks

# Export Kings border with buffer (Import of shapefiles to USGS Geo Data Portal failed)
# kings_border_buf <- st_buffer(kings_border, 0.1)
# st_write(kings_border_buf, "data/gis/kings_border_buf.shp")

# ---------------------------------------------------------------------
# Gridmet processing
# Website: https://cida.usgs.gov/gdp/client/#!catalog/gdp/dataset/54dd5df2e4b08de9379b38d8

# Spatial - Shapefile importer did not work, the boundry was drawn by eye

# Data Detail - Downloaded precip (mm), tmin (K) and tmax (K). Period from 1/1/79 to 12/31/2016.

# Algorithm Selected - Choose OPeNDAP Subset and output as netcdf


# ---------------------------------------------------------------------
# Process data

# Change K to C
k_to_c <- function(x){
    x <- x - 273.15   # K to C
    return(x)
}

# Break up Gridmet ncdf into years
full_nc_to_years_nc <- function(full_nc, start_y, end_y, out_name){
  
  # Replace name actual date Gridnet date corresponds to the number of days since
  # Jan 1 1900. Changing name to a number and then subtracting 25567 days so that new
  # number is equal to days since Jan 1, 1970, which is the dates in lubridate uses
  # as origin.
  
  # Need to manually create output folders for writeRaster 
  
  # Change date of each raster
  nc_date <- full_nc %>% 
    names() %>% 
    str_replace("X", "") %>% 
    as.integer() %>% 
    `-` (25567) %>% 
    as_date()
  
  nc_y <- year(nc_date)
  
  for (aa in seq(start_y,end_y)){
    layers <- nc_y == aa
    layers_row <- row_number(layers)[layers]     # Selects the row numbers
    raster_annual <- full_nc[[layers_row]]
    writeRaster(raster_annual, filename=paste("data/gridmet/", out_name, "_", aa, ".nc", sep=""), overwrite=TRUE)
  }
}


precip <- brick("data/gridmet/kings_precip.nc")
tmin <- brick("data/gridmet/kings_tmin.nc")
tmax <- brick("data/gridmet/kings_tmax.nc")
wind <- brick("data/gridmet/kings_wind.nc")
hum <- brick("data/gridmet/kings_specific_humidity.nc")
rad <- brick("data/gridmet/kings_radiation.nc")

full_nc_to_years_nc(full_nc = precip,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="precip/precip")

tmin1 <- k_to_c(tmin)
full_nc_to_years_nc(full_nc = tmin1,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="tmin/tmin")

tmax1 <- k_to_c(tmax)
full_nc_to_years_nc(full_nc = tmax1,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="tmax/tmax")

full_nc_to_years_nc(full_nc = wind,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="wind/wind")

full_nc_to_years_nc(full_nc = hum,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="hum/hum")

full_nc_to_years_nc(full_nc = rad,
                    start_y=1979, 
                    end_y=2016, 
                    out_name="rad/rad")




#happy <- brick("data/gridmet/precip_1980.nc")
#happy <- brick("data/gridmet/tmax/tmax_1980.nc")

