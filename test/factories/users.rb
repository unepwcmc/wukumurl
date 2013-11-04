FactoryGirl.define do
  factory :user do
    email "hats@boats.com"
    password "password"
    confirmed_at Time.now
  end
end
