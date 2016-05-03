loadPackages()
road<-readGeoData()
#initgps<-initGpsData(x)
#gdata<-readGpsData(x)
#matches<-match(road,initgps,gdata)
#printMatches(matches)
match<-function(x) {
  initgps<-initGpsData(x)
  gdata<-readGpsData(x)
  matches<-match(road,initgps,gdata)
}
