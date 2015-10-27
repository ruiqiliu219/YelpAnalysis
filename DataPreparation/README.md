####getData.py
The python script 
* 1) Scrapes 100 pages of yelp search results and stores features include:
restuarant name, price, rating, business categories and location.
* 2) Accesses Yelp API and get resturant name, location and geographic coordinate
* 3) Inner joins business features and coordinates and write the result to csv file

####Note:
For the final csv file:
* The missing coordinates in the dataset were then filled with google search results
* Categories where no or only restuarant falls in were removed
