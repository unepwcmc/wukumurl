class DisregardVote < ActiveRecord::Base
  belongs_to :organization
  belongs_to :short_url
end
