class Team < ActiveRecord::Base
  validates :name, presence: true, uniqueness:true
  has_many :users, dependent: :nullify
  has_many :short_urls, through: :users

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def visits_this_month
    return [] if users.count.zero?
    Visit.find_by_sql(["
      SELECT visits.*, COUNT(visits.id) as count
      FROM visits
      INNER JOIN
        (
          SELECT id
          FROM short_urls
          WHERE user_id IN (?)
          GROUP BY id
        ) AS short_urls_for_visits
        ON visits.short_url_id = short_urls_for_visits.id
        WHERE visits.created_at > (?)
      GROUP BY visits.id
    ", users.pluck(:id).map(&:to_i), 1.month.ago])
  end

  def visits_per_day
    array = visits_this_month.group_by {|x| x.created_at.strftime("%Y-%m-%d")}
    array.each_with_object({}) { |(k,v), hash| hash[k] = v.length }
  end

  def visits_by_country
    return [] if users.count.zero?
    City.find_by_sql(["
      SELECT cities.country
      FROM cities
      INNER JOIN
        (
          SELECT
            COUNT(visits.id) as value, visits.city_id, visits.short_url_id
          FROM visits
          GROUP BY city_id, short_url_id
        ) AS visits_for_orgs
      ON visits_for_orgs.city_id = cities.id
      INNER JOIN
        (
          SELECT short_urls.id
          FROM short_urls
          WHERE user_id IN (?)
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
      GROUP BY cities.country
    ", users.pluck(:id).map(&:to_i)])
  end

  def all_visits_by_organization
    return [] if users.count.zero?
    Organization.find_by_sql(["
      SELECT organizations.name, SUM(visit_count)::Integer as visit_count
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
          WHERE user_id IN (?)
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
      GROUP BY organizations.name
      ORDER BY visit_count DESC
      LIMIT 10
    ", users.pluck(:id).map(&:to_i)])
  end

  def total_visits
    return [] if users.count.zero?
    Visit.find_by_sql(["
      SELECT visits.*, COUNT(visits.id) as count
      FROM visits
      INNER JOIN
        (
          SELECT id
          FROM short_urls
          WHERE user_id IN (?)
          GROUP BY id
        ) AS short_urls_for_visits
        ON visits.short_url_id = short_urls_for_visits.id
      GROUP BY visits.id
    ", users.pluck(:id).map(&:to_i)])
  end

  def total_urls
    users.inject(0) {|sum, user|
      sum = sum + user.short_urls.count
      sum
    }
  end

  def self.visits_by_team
    Team.find_by_sql(
      "SELECT teams.name, teams.slug, count(*) as visit_count
        FROM short_urls
        INNER JOIN users ON
        users.id = user_id
        INNER JOIN teams ON
        teams.id = team_id
        INNER JOIN visits ON
        short_urls.id = short_url_id
      GROUP BY teams.name, teams.slug
      ORDER BY visit_count DESC")
  end

  def top_referrals
    array = self.total_visits.group_by(&:referrer)
    h = array.map {|k,v| [k ||= "No Domain", v = v.length]}.to_h
    h.sort_by{|k,v| v}.reverse.first(10)
  end

  def self.multiline_visits_graph
    array = []
    self.all.each do |team|
      array << {name: team.name, data: team.visits_per_day} unless team.visits_per_day.empty?
    end
    array
  end
end
