class Team < ActiveRecord::Base
  validates :name, presence: true, uniqueness:true
  has_many :users, dependent: :nullify
  has_many :short_urls, through: :users

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def visits_by_country
    # TODO - Add SQL
    []
  end

  def all_visits_by_organization
    []
  end
end
