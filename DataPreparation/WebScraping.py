import requests
from bs4 import BeautifulSoup


url_params = 'http://www.yelp.com/search?find_desc=Restaurants&find_loc=Minneapolis,+MN&start='

file = open("Category.csv",'r')
category = file.readlines()
full_category = [i.strip() for i in category]



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
        Returns a string to be written in csv (comma seperated) format
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

    feature = name + ',' + str(rating) + ',' + str(reviewCount) + ',' + str(price)+ ',' \
                      + isInCategory + location + '\n'
    return feature




def categoricalVariable(list):
    '''Reads in a specific business category and the full category list
       if the business category matches a value in full category, returns 1 for this category
       otherwise returns 0
    '''
    isIncategory = ''
    for i in range(len(full_category)):
        if full_category[i] in list:
            isIncategory += '1,'
        else:
            isIncategory += '0,'
    return isIncategory


def main():
    numberOfPage = 0
    fileOut = open('yelpdata.csv','a')
    fileOut.write("name,rating,reviewNum,price," + ', '.join(full_category) + ",location\n")

    while(numberOfPage <= 100):
        #Create connection and load content
        url = url_params + str(10 * numberOfPage)
        soup = requestBusinesses(url)

        print("geting page num" + str(numberOfPage))
        #output data line by line
        for x in range(10):
            try:
                line = getFeatures(soup,x)
                print(line)
                fileOut.write(line)
            except IndexError: #If the business do not have a rating, skip it
                x += 1
        numberOfPage += 1

    fileOut.close()
    
    
###########################
if __name__=="__main__":
	main()
###########################
