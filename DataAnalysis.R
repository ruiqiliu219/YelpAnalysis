yelpdata = read.csv("yelpdata.csv",na.strings = "NaN",sep = ',',header = TRUE)
yelpdata = cbind(yelpdata[,c(1:4,68:70)],sapply(yelpdata[,c(5:67)],as.factor))
yelpdata$goodOrBad =factor(ifelse(yelpdata$rating >= 4, "good", "bad"))


coordinates = data.frame(yelpdata$lon,yelpdata$lat)
set.seed(11)
km = kmeans(coordinates,centers = 10)
yelpdata= cbind(yelpdata,km[1])
yelpdata$cluster <- as.factor(yelpdata$cluster)
fit = glm(goodOrBad ~ . , data = yelpdata[c(3,4,10,11,12,18,71,72)],family = "binomial")







