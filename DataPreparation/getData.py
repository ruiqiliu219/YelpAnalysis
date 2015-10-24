import rauth
import json
from urllib.request import urlopen
from urllib.error import URLError


url = 'https://api.yelp.com/v2/search/?term=restaurant &location=Minneapolis'

CONSUMER_KEY = 'MIPqZvPuCQFjIH8L1xMqLQ'
CONSUMER_SECRET = 'nn8wcxfnKOHyJBJTnjfWml7gsM4'
TOKEN = 'rmukoSok1VVruMAEiZ33SCB5ltXvbUAY'
TOKEN_SECRET = 'gS4mZafZlS7U_AblHma7nmyiamc'


def get_search_parameters(restaurant,location):
  params = {}
  params["term"] = restaurant
  params["location"] = location
  params["limit"] = "100"

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

def firstClean(data):
    all_businesses = data["businesses"]
    name =
    coordiante.latitude
    coordiante.longitude


