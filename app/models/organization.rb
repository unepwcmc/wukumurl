class Organization < ActiveRecord::Base
  has_many :visits
  has_many :disregard_votes

  def self.find_or_create_by_max_mind_attributes attributes
    Organization.where(attributes).first || Organization.create(attributes)
  end

  def self.all_visits_by_organization
    select("name, count(*) as visit_count").
      joins(:visits).
      group(:name).
      order('visit_count desc')
  end
end
