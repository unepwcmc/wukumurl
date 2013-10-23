FactoryGirl.define do
  factory :location do
    lat 1.5
    lon 1.5
    source "fsm"
  end

  factory :visit do
    ip_address "194.59.188.126"
  end

  factory :short_url do
    short_name "HackerNews"
    url "http://news.ycombinator.com"
  end
end
