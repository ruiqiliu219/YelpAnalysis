##.......   preparation .........##
library(MASS)
allin = read.csv("yelpdata.csv",na.strings = "NaN",sep = ',',header = TRUE)
yelp = cbind(allin[,c(1:4,68:70)],sapply(allin[,c(5:67)],as.factor))


# K-means Clustering for Location
coordinates = data.frame(yelp$longitude,yelp$latitude)
set.seed(12)
km = kmeans(coordinates,centers = 19)[1]$cluster
yelp$cluster <- ifelse(km == 1,"Nokomis",
                ifelse(km == 2, "Lering Park",
                ifelse(km ==3, "Columbia Heights",
                ifelse(km ==4,"Calhoun Isles",
                ifelse(km == 5,"Golden Vally",
                ifelse(km == 6, "Southwest",
                ifelse(km == 7, "Uptown",
                ifelse(km == 8, "Out Camden",
                ifelse(km ==9, "Far South",
                ifelse(km == 10, "Bloomington",
                ifelse(km == 11, "Northeast",
                ifelse(km == 12, "Longfellow",
                ifelse(km == 13, "Falcon Height",
                ifelse(km == 14, "University",
                ifelse(km == 15, "Powerderhorn",
                ifelse(km == 16, "Downtown",
                ifelse(km == 17, "North Loop",
                ifelse(km == 18, "Near North",
                ifelse(km == 19, "Edina",NA)))))))))))))))))))

attach(yelp)

#Clustering map
theme_set(theme_bw(16))
map = get_map(location = 'minneapolis',zoom = 12,maptype = 'toner')
area = readShapePoly("/Users/ruiqiliu/Desktop/UMN/STAT4986W/FinalProject/Vistualization/City_Boundary.shp")
ggmap(map,extent = "device")+
        geom_polygon(aes(x = long,y = lat,group = group),alpha = 0.15,fill = 'black',data = area)+
        geom_point(data = yelp,aes(longitude,latitude,color = cluster)) +
        theme(legend.position = "right", legend.background = element_rect(color = "black", 
              fill = "white", size = 1, linetype = "solid"), legend.direction = "vertical")
        

##.............. data summary .................##
lapply(yelp,table)

#category summary
cate_name = colnames(allin[,5:67])
cate_num = colSums(allin[,5:67])
category = data.frame(cate_name,cate_num)
category = category[order(category$cate_num),]
par(mar=c(5.1,5,4.1,2.1))
bplt = barplot(height = category$cate_num, names.arg = category$cate_name,horiz = T,
               las = 2,cex.names=.5,xlab = "Number of Resturants")
text(x= category$cate_num+2, y= bplt, labels=as.character(category$cate_num), xpd=TRUE,cex = .5)

#cluster summary
par(mar=c(4.1,6,2.1,2.1))
loc = tapply(longitude,cluster,length)
bplt2 = barplot(loc,las = 2,horiz = T,cex.name = .8)
text(x = loc + 3, y = bplt2, labels=as.character(loc),xpd = T,cex = .8)

#rating summary
par(mar=c(4.1,6,2.1,2.1))
rat = tapply(longitude,rating,length)
bplt3 = barplot(rat,las = 2,cex.name = .8,xlab = "Rating", ylab = "Count")
text(y = rat + 8, x = bplt2, labels=as.character(rat),xpd = T,cex = .8)

##review Count
hist(reviewCount,breaks = 100,xlab = "Number of Reviews", main = "Histogram of number of reviews")

##.................  data analysis  ................ ##
#Does rating vary from location to location?
tapply(rating,cluster,mean)
tapply(rating,cluster,sd)
bartlett.test(rating ~ cluster, data=InsectSprays)
summary(aov(rating ~ cluster,data = yelp))


#How much is the difference?
m <- polr(factor(rating) ~  price + cluster + American.Traditional. + AsianFusion + Cafes +
                  Chinese + FastFood + Salad + Vegetarian + Spanish + Mexican,
          data = yelp, Hess=TRUE)

summary(m)








