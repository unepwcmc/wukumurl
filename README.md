wukumurl
========

url shortener and analytics

## MaxMind
We're using Max Mind GeoIP databases (CountryLite and Organization) to analyse the ip addresses of users. We're using this gem, checkout the install instructions for setup details:

  https://github.com/mtodd/geoip#install

You will then need to setup a config/max_mind.yml file with the locations of your MaxMind DBs. An example of this is in config/max_mind.yml.example
