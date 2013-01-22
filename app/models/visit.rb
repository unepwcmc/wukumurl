class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id

  belongs_to :short_url
end
