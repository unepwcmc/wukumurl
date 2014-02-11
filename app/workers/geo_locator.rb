require 'geoip'
require 'geocoder'

class GeoLocator
  include Sidekiq::Worker

  def perform(visit_id)
    visit = Visit.find(visit_id)

    return if visit.geolocated?

    cdb = GeoIP::City.new(GEO_IP_CONFIG['city_db'])
    orgdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    visit.geo_locate cdb,orgdb

    if visit.save! && visit.geolocated?
      update_orgs_by_short_url visit
      update_orgs_by_user visit
      update_orgs visit
    end
  end

  def update_orgs_by_short_url visit
    short_url    = visit.short_url
    organization = visit.organization
    location     = visit.location

    existing_short_url = CartoDB::Connection.query("
      SELECT COUNT(*)
      FROM #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
      WHERE short_url_id=#{short_url.id}
      AND org_id=#{organization.id}
    ")

    if existing_short_url[:rows].first[:count] > 0
      short_url_query = "
        UPDATE #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
        SET visits=visits+1
        WHERE short_url_id = #{short_url.id}
        AND org_id=#{organization.id}
      "
    else
      short_url_query = "
        INSERT INTO #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
        (the_geom, org_id, org_name, short_url_id, visits)
        VALUES (
          ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
          #{organization.id},
          $$#{CGI.escape organization.name}$$,
          #{short_url.id},
          1
        )
      "
    end

    CartoDB::Connection.query CGI.escape(short_url_query)
  end

  def update_orgs_by_user visit
    short_url    = visit.short_url
    organization = visit.organization
    location     = visit.location

    if short_url.user_id
      existing_user = CartoDB::Connection.query("
        SELECT COUNT(*)
        FROM #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_user']}
        WHERE user_id=#{short_url.user_id}
        AND org_id=#{organization.id}
      ")

      if existing_user[:rows].first[:count] > 0
        user_query = "
          UPDATE #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_user']}
          SET visits=visits+1
          WHERE user_id = #{short_url.user_id}
          AND org_id=#{organization.id}
        "
      else
        user_query = "
          INSERT INTO #{CARTODB_CONFIG['tables'][Rails.env]['organizations_by_user']}
          (the_geom, org_id, org_name, user_id, visits)
          VALUES (
            ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
            #{organization.id},
            $$#{CGI.escape organization.name}$$,
            #{short_url.user_id},
            1
          )
        "
      end

      CartoDB::Connection.query CGI.escape(user_query)
    end
  end

  def update_orgs visit
    organization = visit.organization
    location     = visit.location

    existing_org = CartoDB::Connection.query("
      SELECT COUNT(*)
      FROM #{CARTODB_CONFIG['tables'][Rails.env]['visits_by_organization']}
      WHERE org_id=#{organization.id}
    ")

    if existing_org[:rows].first[:count] > 0
      org_query = "
        UPDATE #{CARTODB_CONFIG['tables'][Rails.env]['visits_by_organization']}
        SET visits = visits + 1
        WHERE org_id=#{organization.id}
      "
    else
      org_query = "
        INSERT INTO #{CARTODB_CONFIG['tables'][Rails.env]['visits_by_organization']}
        (the_geom, org_id, org_name, visits)
        VALUES (
          ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
          #{organization.id},
          $$#{CGI.escape organization.name}$$,
          1
        )
      "
    end

    CartoDB::Connection.query CGI.escape(org_query)
  end
end
