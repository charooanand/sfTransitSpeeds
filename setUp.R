rm(list=ls())

#################################
# reading and manipulating data #
#################################
library(tidyverse)
library(vroom)

#############
# GIS tools #
#############
library(sf)
library(tigris)
library(geosphere)
library(tidygeocoder)
library(tidycensus)
options(tigris_use_cache = TRUE)
censusKey <- "962b1f7e15b2baf3da3c764bee3713d298edb1b3"
census_api_key(censusKey, overwrite = TRUE, install = TRUE)

###########################
# computing transit times #
###########################
options(java.parameters = "-Xmx4G")
Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-21")
library(rJava)
library(tidytransit)
library(r5r)

#################
# visualization #
#################
library(ggplot2)
library(leaflet)
library(plotly)
library(emo)
library(shiny)
library(shinydashboard)

