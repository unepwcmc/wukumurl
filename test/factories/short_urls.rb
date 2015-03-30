FactoryGirl.define do
  factory :short_url do
    url "http://news.ycombinator.com"
    user
  end
end
