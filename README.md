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

### Production

In production, the `SECRET_TOKEN` env variable must be set for the
`secret_key_base` config initializer. We use
[dotenv](https://github.com/bkeepers/dotenv) for managing
environment variables. This should be setup automatically by the deploy
scripts.

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

## DasBoard Metrics

Wukumurl has beta integration with [Dasboard](unepwcmc/DasBoard). Visit
counts for specified `ShortUrl`s will be automatically posted to
DasBoard every hour.

### Configuring a ShortUrl to post automatically

`ShortUrl` models have a `dasboard_metric_name` attribute, which should
match to a configuration option in `config/dasboard.yml`:

    production:
      metrics:
        wdpa_release_downloads: 3

The corresponding number is the metric ID from your DasBoard instance.

Add your metric name and ID to this config file, and set the
`dasboard_metric_name` on your `ShortUrl` to the matching name in the
config.


## Useful to know

If needed, directly on cartodb:
```sql
UPDATE wcmc_io_organizations_by_short_url
SET the_geom_webmercator = ST_Transform(the_geom, 3857)
WHERE
the_geom_webmercator is null;
```
