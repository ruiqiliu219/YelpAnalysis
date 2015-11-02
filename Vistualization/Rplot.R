#Clustering map
library(ggplot2)
library(ggmap)
library(maptools)

yelpdata = read.csv("yelpdata.csv",na.strings = "NaN",sep = ',',header = TRUE)
coordinates = data.frame(yelpdata$lon,yelpdata$lat)
set.seed(11)
km = kmeans(coordinates,centers = 10)
yelpdata= cbind(yelpdata,km[1])
yelpdata$cluster <- as.factor(yelpdata$cluster)

map = get_map(location = 'minneapolis',zoom = 11,maptype = 'toner')
area = readShapePoly("/Users/ruiqiliu/Desktop/UMN/STAT4986W/FinalProject/Vistualization/City_Boundary.shp")
ggmap(map)+
        geom_polygon(aes(x = long,y = lat,group = group),alpha = 0.2,fill = 'black',data = area)+
        geom_point(data = yelpdata,aes(longitude,latitude,color = cluster))