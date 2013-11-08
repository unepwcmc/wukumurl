class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :short_urls

  def no_urls_yet? 
    self.short_urls.find_by_id(self.id) == 0
  end
end
