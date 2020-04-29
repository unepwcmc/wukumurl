FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "hats#{n}@unep-wcmc.org" }
    password "password"
    confirmed_at Time.now
  end
end
