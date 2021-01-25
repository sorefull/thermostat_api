# == Schema Information
#
# Table name: readings
#
#  id             :bigint           not null, primary key
#  battery_charge :float
#  humidity       :float
#  number         :string
#  temperature    :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  thermostat_id  :integer
#
class Reading < ApplicationRecord
  belongs_to :thermostat
end
