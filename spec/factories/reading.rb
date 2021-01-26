FactoryBot.define do
  factory :reading do
    battery_charge { rand * 100 }
    humidity { rand * 100 }
    temperature { rand * 100 }
    number { (rand * 100).to_i }

    thermostat
  end
end
