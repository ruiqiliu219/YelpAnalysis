##.......   preparation .........##
library(MASS)
library(maptools)
library(ggplot2)
library(ggmap)
library(car)

allin = read.csv("yelpdata.csv",na.strings = "NaN",sep = ',',header = TRUE)
yelp = cbind(allin[,c(1:4,68:70)],sapply(allin[,c(5:67)],as.factor))
#remove points that are out of district boundery 
yelp = yelp[which(yelp$longitude > -93.33 & yelp$longitude < -93.2 & yelp$latitude > 44.89 & yelp$latitude <45.05 ),]

## K-means Clustering for Location
coordinates = data.frame(yelp$longitude,yelp$latitude)
set.seed(100)
#determine K 
wss <- (nrow(coordinates)-1)*sum(apply(coordinates,2,var))
for (i in 2:30) wss[i] <- sum(kmeans(coordinates, centers=i)$withinss)
plot(1:30, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares",main = "Determine Cluster Size K,K =11")

cat("model-based optimal number of clusters:", m.best, "\n")
#apply algorithm
km = kmeans(coordinates,centers = 11)[1]$cluster
yelp$cluster = as.factor(km)


#Clustering map
theme_set(theme_bw(16))
map = get_map(location = 'minneapolis',zoom = 12,maptype = 'toner')
area = readShapePoly("/Users/ruiqiliu/Desktop/UMN/STAT4986W/FinalProject/Vistualization/City_Boundary.shp")
lon = tapply(yelp$longitude,yelp$cluster,mean)
lat = tapply(yelp$latitude,yelp$cluster,mean)
txt = c(1:11)
txt_label = data.frame(txt,lon,lat)
ggmap(map,extent = "device")+ 
        geom_polygon(aes(x = long,y = lat,group = group),alpha = 0.15,fill = 'black',data = area)+
        geom_point(data = yelp,aes(longitude,latitude,color = cluster)) +
        geom_text(data = txt_label,aes(lon,lat,label = txt),size = 8) +
        theme(legend.position = "right", legend.background = element_rect(color = "black", 
              fill = "white", size = 1, linetype = "solid"), legend.direction = "vertical")
     

##.............. data summary .................##
lapply(yelp,table)

#category summary
cate_name = colnames(allin[,5:67])
cate_num = colSums(allin[,5:67])
category = data.frame(cate_name,cate_num)
category = category[order(category$cate_num),]
par(mar=c(5.1,5,2.1,2.1))
bplt = barplot(height = category$cate_num, names.arg = category$cate_name,horiz = T,
               las = 2,cex.names=.5,xlab = "Number of Resturants")
text(x= category$cate_num+2, y= bplt, labels=as.character(category$cate_num), xpd=TRUE,cex = .5)

#cluster summary
par(mar=c(4.1,6,2.1,2.1))
loc = tapply(yelp$longitude,yelp$cluster,length)
bplt2 = barplot(loc,las = 2,horiz = T,cex.name = .8,ylab = "Cluster")
text(x = loc + 3, y = bplt2, labels=as.character(loc),xpd = T,cex = .8)

#rating summary
par(mar=c(4.1,6,2.1,2.1))
rat = tapply(yelp$longitude,yelp$rating,length)
bplt3 = barplot(rat,las = 2,cex.name = .8,xlab = "Rating", ylab = "Count")
text(y = rat + 8, x = bplt2, labels=as.character(rat),xpd = T,cex = .8)

##review Count
hist(reviewCount,breaks = 100,xlab = "Number of Reviews", main = "Histogram of number of reviews")

##.................  data analysis  ................ ##
#Does rating vary from location to location?
tapply(yelp$rating,yelp$cluster,mean)
tapply(yelp$rating,yelp$cluster,sd)
summary(aov(rating ~ cluster,data = yelp))
plot(lm(rating~cluster,data = yelp))


#How much is the difference?
#OLS
for(t in unique(yelp$cluster)) {
        yelp[paste("cluster",t,sep="")] <- ifelse(yelp$cluster==t,"1","0")
}
for(p in unique(yelp$price)) {
        yelp[paste("price",p,sep="")] <- ifelse(yelp$price == p, "1","0")
}
OLS = lm(rating ~ .,
        data = yelp[,c(2,11,12,19,23,47,54,65,75,77,80,85)],)
summary(OLS)
par(mfrow = c(2,2))
plot(OLS)
par(mfrow = c(1,1))

#ordinal regression
OR = polr(factor(rating) ~ .,
          data = yelp[,c(2,11,12,19,23,47,54,65,71,85)], Hess=TRUE)

summary(OR)
#prediction rate
exp(OR$coefficients)
deviance <- OR$deviance
fitted = fitted(OR)
expect = rep(0,886)
max = apply(fitted,1,max)
for (i in 1:886){
        for(j in 1:9){
                if(fitted[i,j] == max[i]){
                        expect[i] = (j+1)*0.5
                }
        }
}

true = 0
inc <- function(x){eval.parent(substitute(x <- x + 1))}
for(i in 1:886){
        if(expect[i] == yelp$rating[i]){inc(true)}
}
(rate = true/886)

#How many restaurants are bad-rated but still popular?
fit = lm(log(reviewCount) ~ rating + I(rating^2),yelp)
summary(fit)

avg = median(yelp$reviewCount)
out = yelp[which(yelp$reviewCount > avg & yelp$rating < 3),]
summary(out$cluster)
out$name

