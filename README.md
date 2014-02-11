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

### CartoDB

CartoDB stores a copy of the geolocated Visits so that we can generate
styled map tiles on the fly. You'll need to fill-in and move the example
CartoDB config file `config/cartodb_config.yml.example`.

The `geo_locate:update_map` and `geo_locate:update_all_map` tasks keep
the geolocated Visits in sync with CartoDB.

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

### Countries

The map view requires a list of countries to function. You can seed
these using:

    rake db:seed

## Geolocating

### Sidekiq

Sidekiq is used to automatically geolocate Visits. When a short url is
visited, a job will be created to geolocate it and pushed on to the
Sidekiq queue. The visit stats will also be synced with CartoDB at this
time.

Make sure `redis-server` is running and then run `bundle exec sidekiq`
to process the job queue.

### Manually

You can manually batch geolocate your visits with:

    rake geo_locate:visits

To sync the geolocated visits with CartoDB, you can use:

    rake geo_locate:update_map
    rake geo_locate:update_all_map

You can use the `cap rake_invoke task=<task_name>` to invoke this task on
the server:

    cap rake_invoke task=geo_locate:visits
