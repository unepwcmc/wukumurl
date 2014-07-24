# wcmc.io

URL shortener and analytics

## Setup

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
