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


  # Returns a list of countries with a 'visit_count' attribute
  def visits_by_organization include_disregarded = false
    orgs = Organization.
      select("organizations.id, organizations.name, COUNT(visits.id) as visit_count").
      group("organizations.id, organizations.name").
      joins(:visits).
      where(visits: {short_url_id: self.id})

    unless include_disregarded
      orgs = orgs.where("disregard = false OR disregard IS NULL")
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
