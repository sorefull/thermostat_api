# == Schema Information
#
# Table name: thermostats
#
#  id              :bigint           not null, primary key
#  household_token :string           not null
#  location        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_thermostats_on_household_token  (household_token) UNIQUE
#
class Thermostat < ApplicationRecord
  has_many :readings
end
