class ShortUrl < ActiveRecord::Base
  attr_accessible :short_name, :url
  validates_uniqueness_of :short_name
  validates_presence_of :short_name

  has_many :visits
end
