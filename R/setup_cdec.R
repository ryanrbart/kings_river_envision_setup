# Download and process CDEC data
# Targets: Full Natural Flow, Snow Pillow, Snow Course
# Kings River Station - PNF
# http://cdec.water.ca.gov/queryTools.html
# https://cran.r-project.org/web/packages/CDECRetrieve/vignettes/CDECRetrieve.html

source("R/0_utilities.R")

# ---------------------------------------------------------------------
# Snow Courses (monthly)

# SWE from course is "SNOW, WATER CONTENT(REVISED)", or Sensor # 82

# Read snow courses
snow_course_stations <- read_csv("data/cdec/kings_snow_courses.csv")

# Summary of data products at a station
#cdec_datasets(station = snow_course_stations$ID[3])

# Idenify start date for each station
snow_course_starts <- purrr::map(snow_course_stations$ID, ~cdec_datasets(station = .) %>% 
                                   dplyr::filter(sensor_number==3, duration=="monthly"))
snow_course_starts <- bind_rows(snow_course_starts)

# Generate a list containing snow course data for each station 
snow_course_list <- purrr::map2(snow_course_stations$ID,
                                snow_course_starts$start,
                                ~ cdec_query(station = .x,
                                             sensor_num = "82", 
                                             dur_code = "m", 
                                             start_date = .y, 
                                             end_date = Sys.Date()))

# Combine data into dateframe and spread each station to an individual column
snow_course <- snow_course_list %>% 
  bind_rows() %>% 
  spread(location_id, parameter_value) %>% 
  dplyr::mutate(date = ymd(datetime)) %>% 
  dplyr::select(-agency_cd, -parameter_cd, -datetime)

View(snow_course)

# Export
write_csv(snow_course, "data/cdec/kings_snow_courses_data.csv")


# ---------------------------------------------------------------------
# Snow Pillows (daily)

# SWE from pillows is "SNOW, WATER CONTENT(REVISED)", or Sensor # 82

# ----
# The following was used to establish station data and then it was commented out.
# Vector of snow pillow stations http://cdec.water.ca.gov/reportapp/javareports?name=PAGE6

# snow_pillow_station_ids <- c("bsh", "crl", "stl", "bcb", "mtm", "ubc", "wwc", "bim")
# snow_pillow_stations <- purrr::map(snow_pillow_station_ids, ~ cdec_stations(station_id = .))
# # Elevations for snow_pillow_stations were modified manually
# snow_pillow_stations_df <- bind_rows(snow_pillow_stations)
# write_csv(snow_pillow_stations_df, "data/cdec/kings_snow_pillows.csv")
# ----

# Read snow pillows
snow_pillow_stations <- read_csv("data/cdec/kings_snow_pillows.csv")

# Summary of data products at a station
#cdec_datasets(station = snow_pillow_stations$station_id[1])

# Idenify start date for each station
snow_pillow_starts <- purrr::map(snow_pillow_stations$station_id, ~cdec_datasets(station = .) %>% 
                                   dplyr::filter(sensor_number==82, duration=="daily"))
snow_pillow_starts <- bind_rows(snow_pillow_starts)

# Generate a list containing snow pillow data for each station 
snow_pillow_list <- purrr::map2(snow_pillow_stations$station_id,
                                snow_pillow_starts$start,
                                ~ cdec_query(station = .x,
                                             sensor_num = "82", 
                                             dur_code = "d", 
                                             start_date = .y, 
                                             end_date = Sys.Date()))

# Combine data into dateframe and spread each station to an individual column
snow_pillow <- snow_pillow_list %>% 
  bind_rows() %>% 
  spread(location_id, parameter_value) %>% 
  dplyr::mutate(date = ymd(datetime)) %>% 
  dplyr::select(-agency_cd, -parameter_cd, -datetime)

View(snow_pillow)

# Export
write_csv(snow_pillow, "data/cdec/kings_snow_pillow_data.csv")

# ---------------------------------------------------------------------
# Kings - Full Natural Flow

pnf_full_natural_flow <- cdec_query(station = "pnf", sensor_num = "8", 
                                dur_code = "d", start_date = "1987-05-31", 
                                end_date = Sys.Date())

pnf_full_natural_flow <- pnf_full_natural_flow %>% 
  dplyr::mutate(date = ymd(datetime)) %>% 
  dplyr::select(-agency_cd, -location_id, -parameter_cd, -datetime)

# Export
write_csv(pnf_full_natural_flow, "data/cdec/kings_full_natural_flow_data.csv")


# ---------------------------------------------------------------------
# Output

