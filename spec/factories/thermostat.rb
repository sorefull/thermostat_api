FactoryBot.define do
  factory :thermostat do
    household_token { Faker::Internet.uuid }
    location { Faker::Address.full_address }
  end
end
