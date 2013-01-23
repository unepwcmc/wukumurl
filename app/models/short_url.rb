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
end
