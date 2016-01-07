class User < ActiveRecord::Base
  require 'yaml'

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable

  has_many :short_urls
  belongs_to :team

  def first_name
    name = self.email.partition('@').first
    name.partition('.').first.titleize
  end

  def last_name
    name = self.email.partition('@').first
    name.partition('.').last.titleize
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def team_mates
    User.where(team_id: self.team_id)
  end

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

  def visits_this_month
    Visit.find_by_sql(["
      SELECT visits.*, COUNT(visits.id) as count
      FROM visits
      INNER JOIN
        (
          SELECT id
          FROM short_urls
          WHERE user_id = (?)
          GROUP BY id
        ) AS short_urls_for_visits
        ON visits.short_url_id = short_urls_for_visits.id
        WHERE visits.created_at > (?)
      GROUP BY visits.id", self.id, 1.month.ago])
  end

  def visits_per_day
    array = visits_this_month.group_by {|x| x.created_at.strftime("%Y-%m-%d")}
    array.map {|k,v| [k, v = v.length]}.to_h
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
          WHERE user_id = #{self.id}
          GROUP BY id
        ) AS short_urls_for_visits
      ON visits_for_orgs.short_url_id = short_urls_for_visits.id
    ").group("cities.country").count
  end

  def top_referrals
    array = self.visits.group_by(&:referrer)
    array.map {|k,v| [k ||= "No Domain", v = v.length]}.to_h
  end

  def no_urls?
    self.short_urls.count == 0
  end

  def can_manage? short_url
    # Can manage a link if
    # - it is private and they own it
    # - it is not private but they are in the same team

    if short_url.user
      same_team = (self.team.present? && team == short_url.user.team)
      (short_url.private? && short_url.user == self) ||
      (!short_url.private? && (short_url.user == self || same_team))
    else
      false
    end
  end

  def is_beta?
    self.team.name == YAML.load(File.open("#{Rails.root}/config/secrets.yml"))[Rails.env]["beta_team"]
  end

  def is_owner? short_url
    short_url.user_id == self.id
  end
end
