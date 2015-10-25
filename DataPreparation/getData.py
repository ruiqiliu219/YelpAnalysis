import rauth
import requests
from bs4 import BeautifulSoup
import time


########### Scripping basic features From Yelp Webpage ############
url_params = 'http://www.yelp.com/search?find_desc=Restaurants&find_loc=Minneapolis,+MN&start='

file = open("Category.csv",'r')
category = file.readlines()
full_category = [i.strip() for i in category]
file.close()



def requestBusinesses(url):
    '''querys from the web and get all businesses in one page
       Returns soup object
    '''
    req = requests.get(url)
    soup = BeautifulSoup(req.content,"html.parser")
    businesses = soup.html.body.find_all('div',{'class':'search-result natural-search-result'})
    return businesses


def getFeatures(onePage,index):
    '''Takes in a soup object and the index of business
        Returns a dictionry
    '''

    name = onePage[index].find_all('a',{"class":"biz-name"})[0].text
    reviewCount= onePage[index].find_all("span",{"class":"review-count rating-qualifier"})[0].text.strip().split(' ')[0]
    try:
        price = onePage[index]("span",{"class":"business-attribute price-range"})[0].text
    except IndexError:
        price = 'NaN'

    location = onePage[index].find_all("div",{"class":"secondary-attributes"})[0].span.text.strip()
    if(location == 'Phone number'):
        location = 'NaN'

    rating = onePage[index].find_all("div",{"class" : "rating-large"})[0].i.img.get('alt')[:3]

    category = onePage[index].find_all("span",{"class":"category-str-list"})[0].text.replace(' ','').replace(',','').split('\n')
    category = [x for x in category if x != ''] 
    isInCategory = categoricalVariable(category) #create categorial variables

    feature = {"name" :name,'location':location,'reviewCount':reviewCount,'price':price,"category":isInCategory,
               'rating':rating}
    return feature



def categoricalVariable(list):
    '''Reads in a specific business category and the full category list
       if the business category matches a value in full category, returns 1 for this category
       otherwise returns 0
    '''
    isIncategory = []
    for i in range(len(full_category)):
        if full_category[i] in list:
            isIncategory += [1]
        else:
            isIncategory += [0]
    return isIncategory


def webScripping():
    numberOfPage = 0
    businesses =  []

    while(numberOfPage <= 99):
        #Create connection and load content
        url = url_params + str(10 * numberOfPage)
        soup = requestBusinesses(url)

        print("geting page num" + str(numberOfPage))
        #output data line by line
        for x in range(10):
            try:
                feature = getFeatures(soup,x)
                businesses +=[feature]
            except IndexError: #If the business do not have a rating, skip it
                x += 1
        numberOfPage += 1
        time.sleep(1.0)
    return businesses


########### API Access for Coordianate ###########

CONSUMER_KEY = ''
CONSUMER_SECRET = ''
TOKEN = ''
TOKEN_SECRET = ''


def getSearchParameters(offset):
  params = {}
  params["term"] = 'restaurant'
  params["location"] = 'minneapolis'
  params["limit"] = "20"
  params["offset"] = str(offset)

  return params


def request(params):
    """
    Obtains data from yelp as JSON API
    Returns the raw data as python dictionary
    """

    consumer_key = CONSUMER_KEY
    consumer_secret = CONSUMER_SECRET
    token = TOKEN
    token_secret = TOKEN_SECRET

    session = rauth.OAuth1Session(
        consumer_key = consumer_key
        ,consumer_secret = consumer_secret
        ,access_token = token
        ,access_token_secret = token_secret)

    request = session.get("http://api.yelp.com/v2/search",params=params)

    #Transforms JSON API response into a Python dictionary
    data = request.json()
    session.close()

    return data


def getCoordinate(data):
    all_businesses = data["businesses"]
    ls = []
    for item in all_businesses:
        name = item['name']
        try:
            location = item['location']['neighborhoods']
        except KeyError:
            location = 'NaN'
        try:
            latitude = item['location']['coordinate']['latitude']
            longitude = item['location']['coordinate']['longitude']
        except KeyError:
            latitude = 'NaN'
            longitude = 'NaN'
        dic = {'name':name,'location':location,'latitude':latitude,"longitude":longitude}
        ls += [dic]
    return ls



def requestAllCoordinates():
    '''read in 20 records per time until reach 980 items'''
    coordinates = []
    offset = 0
    while offset <= 980:
        paras = getSearchParameters(offset)
        data = request(paras)
        coordinates += getCoordinate(data)
        time.sleep(1.0)
        offset += 20
    return coordinates


########### Inner Join two dictionaries by name and location ###########
def innerJoin(businesses,coordinates):
    '''Inner Join businesses dictionary and coordinates dictionary
        Use name and location as key
    '''
    for business in businesses:
        for coordinate in coordinates:
            if(business['name'] == coordinate['name'] and business['location'] == coordinate['loaction'][0]):
                business['longitude'] = coordinate['longitude']
                business['latitude'] = coordinate['latitude']





############### Write dictionaries to txt file  ###################
def main():
    businesses = webScripping()
    coordinates = requestAllCoordinates()
    innerJoin(businesses,coordinates)
    Output = open('yelpdata.txt','a')
    Output.write("name,rating,reviewCount,price," + ', '.join(full_category) + ",location,longitude,latitude\n")
    for item in businesses:
        name = item['name']
        rating = item['rating']
        reviewCount = item['reviewCount']
        price = item['price']
        category = str(item['category']).strip('[]')
        location = item['location']
        try:
            longitude = item['longitude']
            latitude = item['latitude']
        except KeyError:
            longitude = 'NaN'
            latitude = 'NaN'
        line = name + ',' + str(rating) + ',' + str(reviewCount) + ',' + price + ',' + category + ',' + \
                location + ',' + str(longitude) + ',' + str(latitude) +'\n'
        print(line)
        Output.write(line)

    Output.close()
    
    
