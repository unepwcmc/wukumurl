class ShortUrl < ActiveRecord::Base
  attr_accessible :short_name, :url
end
