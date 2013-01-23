class ShortUrl < ActiveRecord::Base
  require 'securerandom'
  attr_accessible :short_name, :url
  validates_uniqueness_of :short_name
  before_validation :create_short_name_if_blank

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
end
