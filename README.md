# wcmc.io

URL shortener and analytics

## Setup

### MaxMind

We're using Max Mind GeoIP databases (CountryLite and Organization) to
analyse the ip addresses of users. We're using this gem, checkout the
install instructions for setup details:

  https://github.com/mtodd/geoip#install

You will then need to setup a `config/max_mind.yml` file with the
locations of your MaxMind DBs. An example of this is in
`config/max_mind.yml.example`.

#### Ubuntu setup

Install the geoip from apt:

    apt-get install geoip-bin geoip-database libgeoip-dev

Then find the Max Mind GeoIP databases with locate:

    locate GeoIP

Mine were in `/usr/share/GeoIP`. Drop the extra commercial and city DBs
into this folder, then point your `config/max_mind.yml` to these.

#### Homebrew (OS X) setup

    brew install geoip

Your Max Mind DBs will be in `/usr/local/share/GeoIP/`, add the extras,
then point `config/max_mind.yml` to them.

### Install

Normal rails setup:

* `bundle install`
* `rake db:create`
* `rake db:migrate`

### LDAP

Users are primarily authenticated via LDAP, but the application will use
Users in the local database first if they exist.

In development, `rake db:seed` will create a non-LDAP user to test the
application with:

    * **Email**: dev@wcmc.io
    * **Password**: password

### Countries

The map view requires a list of countries to function. You can seed
these using:

    rake db:seed

## Geolocating

Geolocate your visits with:

    rake geo_locate:visits

You can use the `cap rake_invoke task=<task_name>` to invoke this task on
the server:

    cap rake_invoke task=geo_locate:visits
