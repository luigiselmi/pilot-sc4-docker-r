# R script to map match the position (long,lat) of taxies to links in a area (Thessaloniki) taken from OpenStreetMap.  
# This script define the functions that will be available to a client that connects to a Rserve. 
# The order in which the functions must be called is as follows
# loadPackages()
# road<-readGeoData()
# initgps<-initGpsData()
# gdata<-readGpsData()
# matches<-match(road,initgps,gdata)
# printMatches(matches)

## Imports and load packages that might not be available by default in R ##
loadPackages <- function() {

  if("rgdal" %in% rownames(installed.packages()) == FALSE) {install.packages("rgdal")}
  if("maptools" %in% rownames(installed.packages()) == FALSE) {install.packages("maptools")}
  if("rgeos" %in% rownames(installed.packages()) == FALSE) {install.packages("rgeos")}
  if("sp" %in% rownames(installed.packages()) == FALSE) {install.packages("sp")}
  if("geosphere" %in% rownames(installed.packages()) == FALSE) {install.packages("geosphere")}
  if("ggplot2" %in% rownames(installed.packages()) == FALSE) {install.packages("ggplot2")}
  if("ggmap" %in% rownames(installed.packages()) == FALSE) {install.packages("ggmap")}

  ## loading libs:
  library(maptools)
  library(rgeos)
  library(sp)
  library(geosphere)
  library(ggplot2)
  library(ggmap) 
  
  print("Libraries loaded.")
}

## Reads geographical data (links from an OpenStreetMap data set) ##
readGeoData <- function() {
  # read shapefile with the spatial data
  # THIS IS A TEST SUB-NETWORK FROM OSM. LOADING MIGHT CHANGE TOWARDS OSM BASED METHODS
  road <- readShapeSpatial("/home/sc4pilot/geodata/links_OSM_VOlgasSection")
  # define projection
  proj4string(road) <- "+proj=longlat +datum=WGS84"
  road
}


## Init GPS data ##
initGpsData <- function(x) {
  gData.init<-x
  gData.init$id <- as.numeric(rownames(gData.init))
  gData<-gData.init
  gData.init$mapLong<-NA
  gData.init$mapLat<-NA
  gData.init$mapID<-NA
  gData.init
}

## Reads GPS data ##
readGpsData <- function(x) {
  
  gData.init<-x
  gData.init$id <- as.numeric(rownames(gData.init))
  gData<-gData.init
  gData.init$mapLong<-NA
  gData.init$mapLat<-NA
  gData.init$mapID<-NA
  # Make a spatialPointDataFrame
  coordinates(gData) <- gData[c("longitude", "latitude")]
  # Define its projection
  proj4string(gData) <- "+proj=longlat +datum=WGS84" 
  gData 
}

## Proximity & Candidates ##
match <- function(road,gData.init,gData) {
  
  # arrays for timings
  innerLoop <- c(0) 
  outerLoop <-c(0)
  counter   <-1
  
  deviceIDs = unique(gData$device_id)
  ndevices  = length(deviceIDs)

  # make a candidate df (max number of candidate links = 5) 
  nCand<-5
  
  # Transform Gps data for a greek projection
  gDataIn2100 <- spTransform( gData, CRS("+init=epsg:2100") )
  
  # Transform Geo data for a greek projection
  roadIn2100 <- spTransform( road, CRS("+init=epsg:2100") )

  for (i in 1:ndevices){
    t1 <- Sys.time(); # timing
    ePositionsIn2100 <- gDataIn2100[(gDataIn2100$device_id==deviceIDs[i]), ] # subset of data per device (GGRS80)
    ePositions <- gData[(gData$device_id==deviceIDs[i]), ] # subset of data per device 
  
    # find all distances
    distFromNet <- gDistance(ePositionsIn2100, roadIn2100, byid=TRUE)
  
    # find the index of the nCand candidate links (smallest distances)
    CandLinks<-apply(distFromNet, 2, function(X) rownames(distFromNet)[order(X)][1:nCand]) 
  
    # you have a list of candidate links given proximity.
    # TODO: This is one of the metrics to be used. Here, we will add more. 

    # say we have done all the tasks and we have agreed that the most suitable candidate is the first of the CandLinks
    # class. 
    # for each point that you have defined the most probable candidate link
    for(j in 1:length(ePositions)){
      t3<- Sys.time();
      # get the OSM ID
      exPoID<-ePositions@data$id[j]
      # find its index
      inde<-as.numeric(CandLinks[1,j])+1
      selectedCandidate <- road[inde, ] # road[CandLinks[1, ], ]
      osMID<-selectedCandidate@data$full_id
      # find the point that intersects to the closest link. 
      Choosem<-data.frame(dist2Line(ePositions[j, ], selectedCandidate, distfun=distHaversine))
      # Store the information in the gData.Init
      gData.init[gData.init$id == exPoID, c("mapLong")]<-Choosem$lon
      gData.init[gData.init$id == exPoID, c("mapLat") ]<-Choosem$lat
      gData.init[gData.init$id == exPoID, c("mapID") ]<-as.character(osMID)
    
      # count the time it takes
      t4<-Sys.time()
      innerLoop[counter]<-difftime(t4,t3)
      counter<-counter+1
    }
    t2 <- Sys.time()
    outerLoop[i]<-difftime(t2,t1)
  }
  gData.init
}

