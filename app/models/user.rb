class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :short_urls

  def visits
    Visit.find_by_sql("
      SELECT visits.*, COUNT(visits.id) as count
      FROM visits
      INNER JOIN
        (
          SELECT id
          FROM short_urls
          WHERE user_id = #{self.id}
          GROUP BY id
        ) AS short_urls_for_visits
        ON visits.short_url_id = short_urls_for_visits.id
      GROUP BY visits.id
    ")
  end

  def visits_by_organization
    Organization.find_by_sql("
      SELECT organizations.*, visit_count
      FROM organizations
      INNER JOIN
        (
          SELECT
            COUNT(visits.id) as visit_count, visits.organization_id, visits.short_url_id
          FROM visits
          GROUP BY organization_id, short_url_id
        ) AS visits_for_orgs
      ON visits_for_orgs.organization_id = organizations.id
      INNER JOIN
        (
          SELECT short_urls.id
          FROM short_urls
          WHERE user_id = #{self.id}
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
    ")
  end

  def visits_by_country
    result = ActiveRecord::Base.connection.execute("
      SELECT cities.country, visit_count
      FROM cities
      INNER JOIN
        (
          SELECT
            COUNT(visits.id) as visit_count, visits.city_id, visits.short_url_id
          FROM visits
          GROUP BY city_id, short_url_id
        ) AS visits_for_orgs
      ON visits_for_orgs.city_id = cities.id
      INNER JOIN
        (
          SELECT short_urls.id
          FROM short_urls
          WHERE user_id = #{self.id}
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
    ")

    result
  end

  def no_urls?
    self.short_urls.count == 0
  end
end
