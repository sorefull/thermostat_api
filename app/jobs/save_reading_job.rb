# frozen_string_literal: true

class SaveReadingJob < ApplicationJob
  queue_as :default

  def perform(inputs)
    thermostat = Thermostat.find_by_household_token(inputs['household_token'])
    thermostat.readings.create!(sliced(inputs))
  end

  private

  def sliced(inputs)
    inputs.slice('temperature', 'humidity', 'battery_charge', 'number')
  end
end
