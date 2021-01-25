# == Schema Information
#
# Table name: thermostats
#
#  id              :bigint           not null, primary key
#  household_token :string
#  location        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Thermostat < ApplicationRecord
  has_many :readings
end
