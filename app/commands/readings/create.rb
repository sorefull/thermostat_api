# frozen_string_literal: true

module Readings
  # This class is used in Api:ReadingsController
  class Create < Mutations::Command
    required do
      float :temperature
      float :humidity
      float :battery_charge
      string :household_token
    end

    def execute
      set_reading_stats
      set_sum_stats
      set_min_max_stats
      set_sequence_number

      enqueue_readning_save

      sequence_number
    end

    private

    def set_reading_stats
      Rails.configuration.redis.set(
        household_token,
        inputs.slice(:temperature, :humidity, :battery_charge).to_json
      )
    end

    def set_sum_stats
      Rails.configuration.redis.incrbyfloat("#{household_token}.temperature_sum", temperature)
      Rails.configuration.redis.incrbyfloat("#{household_token}.humidity_sum", humidity)
      Rails.configuration.redis.incrbyfloat("#{household_token}.battery_charge_sum", battery_charge)
    end

    def set_min_max_stats
      if Rails.configuration.redis.get("#{household_token}.temperature_min").nil? || Rails.configuration.redis.get("#{household_token}.temperature_min").to_f > temperature
        Rails.configuration.redis.set("#{household_token}.temperature_min", temperature)
      end
      if Rails.configuration.redis.get("#{household_token}.temperature_max").nil? || Rails.configuration.redis.get("#{household_token}.temperature_max").to_f < temperature
        Rails.configuration.redis.set("#{household_token}.temperature_max", temperature)
      end
      if Rails.configuration.redis.get("#{household_token}.humidity_min").nil? || Rails.configuration.redis.get("#{household_token}.humidity_min").to_f > humidity
        Rails.configuration.redis.set("#{household_token}.humidity_min", humidity)
      end
      if Rails.configuration.redis.get("#{household_token}.humidity_max").nil? || Rails.configuration.redis.get("#{household_token}.humidity_max").to_f < humidity
        Rails.configuration.redis.set("#{household_token}.humidity_max", humidity)
      end
      if Rails.configuration.redis.get("#{household_token}.battery_charge_min").nil? || Rails.configuration.redis.get("#{household_token}.battery_charge_min").to_f > battery_charge
        Rails.configuration.redis.set("#{household_token}.battery_charge_min", battery_charge)
      end
      if Rails.configuration.redis.get("#{household_token}.battery_charge_max").nil? || Rails.configuration.redis.get("#{household_token}.battery_charge_max").to_f < battery_charge
        Rails.configuration.redis.set("#{household_token}.battery_charge_max", battery_charge)
      end
    end

    def set_sequence_number
      Rails.configuration.redis.incr("#{household_token}.count")
    end

    def enqueue_readning_save
      SaveReadingJob.perform_later(inputs.merge(number: sequence_number))
    end

    def sequence_number
      @sequence_number ||= Rails.configuration.redis.get("#{household_token}.count")
    end
  end
end
