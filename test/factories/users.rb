FactoryGirl.define do
  factory :user do
    email "hats@unep-wcmc.org"
    password "password"
    confirmed_at Time.now
  end
end
