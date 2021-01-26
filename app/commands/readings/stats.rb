# frozen_string_literal: true

module Readings
  # This class is used in Api:ReadingsController
  class Stats < Mutations::Command
    required do
      string :household_token
    end

    def execute
      {
        avg_temperature: Rails.configuration.redis.get("#{household_token}.temperature_sum").to_f / count,
        min_temperature: Rails.configuration.redis.get("#{household_token}.temperature_min").to_f,
        max_temperature: Rails.configuration.redis.get("#{household_token}.temperature_max").to_f,
        avg_humidity: Rails.configuration.redis.get("#{household_token}.humidity_sum").to_f / count,
        min_humidity: Rails.configuration.redis.get("#{household_token}.humidity_min").to_f,
        max_humidity: Rails.configuration.redis.get("#{household_token}.humidity_max").to_f,
        avg_battery_charge: Rails.configuration.redis.get("#{household_token}.battery_charge_sum").to_f / count,
        min_battery_charge: Rails.configuration.redis.get("#{household_token}.battery_charge_min").to_f,
        max_battery_charge: Rails.configuration.redis.get("#{household_token}.battery_charge_max").to_f
      }
    end

    private

    def count
      @count ||= Rails.configuration.redis.get("#{household_token}.count").to_i
    end
  end
end
