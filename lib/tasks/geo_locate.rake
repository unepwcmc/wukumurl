namespace :geo_locate do
  task visits: :environment do
    require 'geoip'
    require 'geocoder'

    cdb = GeoIP::City.new(GEO_IP_CONFIG['city_db'])
    orgdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    Visit.un_geolocated.each do |visit|
      visit.geo_locate cdb,orgdb
      visit.save
    end
  end

  task update_map: :environment do
    last_update = CartoDB::Connection.query("
      SELECT updated_at
      FROM #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
      ORDER BY updated_at
      DESC LIMIT 1
    ")[:rows].first.try(:updated_at)


    last_update = Date.parse("1 January 1970") if last_update.nil?
    visits_since_last_update = Visit.where('created_at > ?', [last_update])

    abort("nothing to do") if visits_since_last_update.length == 0

    visits = visits_since_last_update.uniq { |v| v.short_url }

    visits.each do |visit|
      short_url    = visit.short_url
      organization = visit.organization
      location     = visit.location

      next unless organization && location

      visit_count = Visit.where(short_url_id: short_url.id).count

      if location.lat && location.lon
        existing_short_url = CartoDB::Connection.query("
          SELECT COUNT(*)
          FROM #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
          WHERE short_url_id=#{short_url.id}
          AND org_id=#{organization.id}
        ")

        if existing_short_url[:rows].first[:count] > 0
          short_url_query = "
            UPDATE #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
            SET visits=#{visit_count}
            WHERE short_url_id = #{short_url.id}
            AND org_id=#{organization.id}
          "
        else
          short_url_query = "
            INSERT INTO #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_short_url']}
            (the_geom, the_geom_webmercator, org_id, org_name, short_url_id, visits)
            VALUES (
              ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
              ST_Transform(ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326), 3857),
              #{organization.id},
              $$#{CGI.escape organization.name}$$,
              #{short_url.id},
              #{visit_count}
            )
          "
        end

        puts short_url_query
        CartoDB::Connection.query short_url_query

        if short_url.user_id
          existing_user = CartoDB::Connection.query("
            SELECT COUNT(*)
            FROM #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_user']}
            WHERE user_id=#{short_url.user_id}
            AND org_id=#{organization.id}
          ")

          if existing_user[:rows].first[:count] > 0
            user_query = "
              UPDATE #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_user']}
              SET visits=#{visit_count}
              WHERE user_id = #{short_url.user_id}
              AND org_id=#{organization.id}
            "
          else
            user_query = "
              INSERT INTO #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['organizations_by_user']}
              (the_geom, the_geom_webmercator, org_id, org_name, user_id, visits)
              VALUES (
                ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
                ST_Transform(ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326), 3857),
                #{organization.id},
                $$#{CGI.escape organization.name}$$,
                #{short_url.user_id},
                #{visit_count}
              )
            "
          end

          puts user_query
          CartoDB::Connection.query user_query
        end
      end
    end
  end

  task update_all_map: :environment do
    org_last_update = CartoDB::Connection.query("
      SELECT updated_at
      FROM #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['visits_by_organization']}
      ORDER BY updated_at
      DESC LIMIT 1
    ")[:rows].first.try(:updated_at)

    org_last_update = Date.parse("1 January 1970") if org_last_update.nil?
    visits_since_last_update = Visit.where('created_at > ?', [org_last_update])

    abort("nothing to do") if visits_since_last_update.length == 0

    visits_since_last_update.each do |visit|
      organization = visit.organization
      location     = visit.location

      next unless organization && location && location.lat && location.lon

      visit_count = Visit.where(organization_id: organization.id).count

      existing_org = CartoDB::Connection.query("
        SELECT COUNT(*)
        FROM #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['visits_by_organization']}
        WHERE org_id=#{organization.id}
      ")

      if existing_org[:rows].first[:count] > 0
        org_query = "
          UPDATE #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['visits_by_organization']}
          SET visits = #{visit_count}
          WHERE org_id=#{organization.id}
        "
      else
        org_query = "
          INSERT INTO #{CARTODB_LAYERS_CONFIG['tables'][Rails.env]['visits_by_organization']}
          (the_geom, the_geom_webmercator, org_id, org_name, visits)
          VALUES (
            ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326),
            ST_Transform(ST_GeomFromText('POINT(#{location.lon} #{location.lat})', 4326), 3857),
            #{organization.id},
            $$#{CGI.escape organization.name}$$,
            #{visit_count}
          )
        "
      end

      puts org_query
      CartoDB::Connection.query org_query
    end
  end
end
