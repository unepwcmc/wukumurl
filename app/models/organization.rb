class Organization < ActiveRecord::Base
  attr_accessible :name
  has_many :visits

  def self.find_or_create_by_max_mind_attributes attributes
    country = Organization.where(attributes).first || Organization.create(attributes)
  end
end
