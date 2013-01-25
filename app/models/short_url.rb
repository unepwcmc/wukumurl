class ShortUrl < ActiveRecord::Base
  require 'securerandom'
  attr_accessible :short_name, :url
  validates_uniqueness_of :short_name
  validate :validate_url
  
  before_validation :create_short_name_if_blank
  before_validation :ensure_http_prepend

  has_many :visits, :dependent => :destroy  

  def create_short_name_if_blank
    unless self.short_name?
      self.short_name = ShortUrl.generate_short_name
    end
  end

  def self.generate_short_name
    SecureRandom.hex(6)
  end

  def visit_count
    Visit.where(short_url_id: self.id).count
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
    Country.select("countries.id, countries.name, COUNT(visits.id) as visit_count")
            .group("countries.id, countries.name")
            .joins(:visits)
            .where(visits: {short_url_id: self.id})
  end

  # Returns a list of countries with a 'visit_count' attribute
  def visits_by_organization
    Organization.select("organizations.id, organizations.name, COUNT(visits.id) as visit_count")
            .group("organizations.id, organizations.name")
            .joins(:visits)
            .where(visits: {short_url_id: self.id})
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
