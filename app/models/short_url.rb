class ShortUrl < ActiveRecord::Base
  require 'securerandom'
  validates_uniqueness_of :short_name
  validate :validate_url

  before_validation :create_short_name_if_blank
  before_validation :sanitise_short_name
  before_validation :ensure_http_prepend

  auto_strip_attributes :url

  has_many :visits, :dependent => :destroy

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

  def owned_by? current_user
    return !current_user.blank? &&
      !current_user.short_urls.find_by_id(self.id).blank?
  end

  def self.generate_short_name
    SecureRandom.hex(2)
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
