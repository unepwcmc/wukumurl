class ShortUrl < ActiveRecord::Base
  require 'securerandom'
  validates_uniqueness_of :short_name
  validate :validate_url
  validate :user, presence: true

  before_validation :create_short_name_if_blank
  before_validation :sanitise_short_name
  before_validation :ensure_http_prepend

  auto_strip_attributes :url

  has_many :visits, :dependent => :destroy
  has_many :locations, :through => :visits
  has_many :cities, :through => :visits
  has_many :country_locations, :through => :cities
  has_many :disregard_votes

  belongs_to :user

  scope :with_visits, -> {
    joins('LEFT JOIN visits ON visits.short_url_id = short_urls.id').
    select('short_urls.*, count(visits.id) AS visits_count').
    group('short_urls.id')
  }

  scope :ordered_by_visits_desc, -> {
    with_visits.
    order('visits_count DESC')
  }

  def self.not_deleted
    where("deleted = false OR deleted IS NULL")
  end

  def owned_by? current_user_or_team
    return false unless current_user_or_team
    !!current_user_or_team.short_urls.find_by_id(id)
  end

  def self.generate_short_name
    SecureRandom.hex(2)
  end

  def visit_count
    Visit.where(short_url_id: self.id).count
  end

  def visits_location
    Visit.where(short_url_id: self.id).select([:id, :longitude, :latitude])
  end

  def visits_today
    self.visits.where(['created_at > ?', Date.today])
  end

  def visits_this_week
    self.visits.where(['created_at > ?', 1.week.ago])
  end

  def visits_this_month
    self.visits.where(['created_at > ?', 1.month.ago])
  end

  # Returns a list of countries with a 'visit_count' attribute
  def visits_by_country
    City.joins(:visits)
    .where(visits: {short_url_id: self.id})
    .group("cities.country").count
  end

  def visits_by_city
    City.select("cities.city_name, COUNT(visits.id) as visit_count")
    .group("cities.city_name")
    .joins(:visits)
    .where(visits: {short_url_id: self.id})
  end

  def visits_by_organization_query
    "
      SELECT organizations.*, visit_count
      FROM organizations
      INNER JOIN
        (
          SELECT
            COUNT(visits.id) as visit_count, visits.organization_id
          FROM visits
          WHERE visits.short_url_id = #{self.id}
          GROUP BY organization_id
        ) AS visits_for_orgs
      ON visits_for_orgs.organization_id = organizations.id
    "
  end

  def pertinent_organization_query threshold = 5
    "
      INNER JOIN
        (
          SELECT
            COUNT(organization_id) as count, organizations.id AS org_id
          FROM organizations
          LEFT OUTER JOIN
            disregard_votes
          ON
            disregard_votes.organization_id = organizations.id
          GROUP BY organizations.id
        ) AS globally_pertinent_organizations
      ON
        globally_pertinent_organizations.org_id = organizations.id
        AND globally_pertinent_organizations.count < #{threshold}
      LEFT OUTER JOIN
        (
          SELECT organization_id
          FROM disregard_votes
          WHERE short_url_id = #{self.id}
          GROUP BY organization_id
        ) AS disregarded_for_short_url_organizations
      ON
        disregarded_for_short_url_organizations.organization_id = globally_pertinent_organizations.org_id
      WHERE
        disregarded_for_short_url_organizations.organization_id IS NULL
      ORDER BY visit_count DESC
    "
  end

  def non_pertinent_organization_query without: {}
    ignore_ids = without.map(&:id).join(', ')
    if ignore_ids.length > 0
      return " WHERE organizations.id NOT IN (#{ignore_ids})"
    end

    return ""
  end

  # Returns a list of countries with a 'visit_count' attribute
  def visits_by_organization group_by_disregarded: true, disregard_threshold: 5
    organizations_query = visits_by_organization_query

    if group_by_disregarded
      pertinent_organizations = Organization.find_by_sql(
        [organizations_query, pertinent_organization_query].join(" ")
      )

      non_pertinent_organizations = Organization.find_by_sql(
        [
          organizations_query,
          non_pertinent_organization_query(without: pertinent_organizations)
        ].join(" ")
      )

      orgs = {
        pertinent: pertinent_organizations,
        non_pertinent: non_pertinent_organizations
      }
    else
      orgs = Organization.find_by_sql([
        organizations_query,
        "ORDER BY visit_count DESC"
      ].join(" "))
    end

    orgs
  end

  private

  def create_short_name_if_blank
    unless self.short_name?
      self.short_name = ShortUrl.generate_short_name
    end
  end

  def sanitise_short_name
    self.short_name.gsub!(/[^\_\-[:alnum:]]+/, "_")
  end

  def ensure_http_prepend
    unless /https{0,1}:\/\/.*/.match self.url
      self.url = "http://#{self.url}"
    end
  end

  require 'uri'

  def validate_url
    begin
      uri = URI.parse(self.url)
      uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      self.errors.add(:url, "does not appear to be valid")
    end
  end
end
