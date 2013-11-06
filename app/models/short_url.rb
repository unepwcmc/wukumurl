class ShortUrl < ActiveRecord::Base
  require 'securerandom'
  validates_uniqueness_of :short_name
  validate :validate_url

  attr_accessor :not_a_robot

  before_validation :create_short_name_if_blank
  before_validation :ensure_http_prepend

  validates :not_a_robot, :inclusion => {
    :in => [true],
    :message => "must be checked"
  }

  auto_strip_attributes :url

  has_many :visits, :dependent => :destroy
  has_many :locations, :through => :visits
  has_many :cities, :through => :visits
  has_many :country_locations, :through => :cities
  has_many :disregard_votes

  belongs_to :user

  def not_a_robot
    if @not_a_robot.nil?
      return true
    end

    @not_a_robot
  end

  def create_short_name_if_blank
    unless self.short_name?
      self.short_name = ShortUrl.generate_short_name
    end
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
    City.select("cities.country, COUNT(visits.id) as visit_count")
    .group("cities.country")
    .joins(:visits)
    .where(visits: {short_url_id: self.id})
  end

  def visits_by_city
    City.select("cities.city_name, COUNT(visits.id) as visit_count")
    .group("cities.city_name")
    .joins(:visits)
    .where(visits: {short_url_id: self.id})
  end

  def visits_from_pertinent_organizations
    Organization.find_by_sql("
      SELECT organizations.*
      FROM organizations
      INNER JOIN visits
      ON short_url_id = #{self.id}
        AND organization_id = organizations.id
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
        AND globally_pertinent_organizations.count < 5
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
    ")
  end

  def visits_from_organizations without: {}
    query = "
      SELECT organizations.*
      FROM organizations
      INNER JOIN visits
      ON short_url_id = #{self.id}
        AND organization_id = organizations.id
    "

    ignore_ids = without.map(&:id).join(', ')
    if ignore_ids.length > 0
      query += " WHERE organizations.id NOT IN (#{ignore_ids})"
    end

    Organization.find_by_sql(query)
  end

  # Returns a list of countries with a 'visit_count' attribute
  def visits_by_organization group_by_disregarded: true, disregard_threshold: 5
    if group_by_disregarded
      pertinent_organizations = visits_from_pertinent_organizations
      non_pertinent_organizations = visits_from_organizations without: pertinent_organizations

      orgs = {
        pertinent: pertinent_organizations,
        non_pertinent: non_pertinent_organizations
      }
    else
      orgs = visits_from_organizations
    end

    orgs
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

  def self.not_deleted
    where("deleted = false OR deleted IS NULL")
  end
end
