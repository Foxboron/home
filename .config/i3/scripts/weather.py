import requests
import xmltodict
#go to yahoo weather, search for your location and note the  number at the end of the url. Should be your weather code.
#uses weather-icons-font which has a few annoying overlaps with font awesome.
url = "http://weather.yahooapis.com/forecastrss?w=857105&u=c"
w = xmltodict.parse(requests.get(url).text)
w = w['rss']['channel']['item']['yweather:condition']

# Add unicode symbol to weather description:
symbols = dict([('Cloudy', ''),
                ('Mostly Cloudy', ''),
                ('Partly Cloudy', ''),
                ('Fog', ""),
                ('Showers', ''),
                ('Light Rain', ''),
                ('Light Rain/Windy', ''),
                ('Thunderstorms', ''),
                ('Sunny', "")])

# If weather description is in the dictionary above, get the symbol.
# If not, leave the symbol blank.
try:
    symbol = symbols[w['@text']]
except KeyError:
    symbol = ''

print(symbol + ' ' + w['@text'] + ' ' + w['@temp'] + '°C')
