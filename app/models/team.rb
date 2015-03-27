class Team < ActiveRecord::Base
  validates :name, presence: true, uniqueness:true
  has_many :users, dependent: :nullify
  has_many :short_urls, through: :users

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def visits_by_country
    City.joins("
      INNER JOIN
        (
          SELECT
            COUNT(visits.id) as value, visits.city_id, visits.short_url_id
          FROM visits
          GROUP BY city_id, short_url_id
        ) AS visits_for_orgs
      ON visits_for_orgs.city_id = cities.id
    ").joins("
      INNER JOIN
        (
          SELECT short_urls.id
          FROM short_urls
          WHERE user_id IN (#{self.users.pluck(:id).join(',')})
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
    ").group("cities.country").count
  end

  def all_visits_by_organization
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
          WHERE user_id IN (#{self.users.pluck(:id).join(',')})
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
    ")
  end

  def total_visits
    Visit.find_by_sql("
      SELECT visits.*, COUNT(visits.id) as count
      FROM visits
      INNER JOIN
        (
          SELECT id
          FROM short_urls
          WHERE user_id IN (#{self.users.pluck(:id).join(',')})
          GROUP BY id
        ) AS short_urls_for_visits
        ON visits.short_url_id = short_urls_for_visits.id
      GROUP BY visits.id
    ")
  end

  def total_urls
    self.users.each_with_object(0) {|user, sum| sum += user.short_urls.count}
  end
end
