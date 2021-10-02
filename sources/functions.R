####
# FUNCTIONS ---------------------------------------------------------------
####


####
####  earth.dist
####

# This function is used to get the distance between two points using the latitude and longitude of each point.
# @param long1: first point longitude
# @param lat1: first point latitude
# @param lat2: second point longitude
# @param lat2: second point latitude

earth.dist <- function (long1, lat1, long2, lat2)
{
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378.145
  d <- R * c
  return(d)
}
