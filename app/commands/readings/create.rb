module Readings
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
      $redis.set(
        household_token,
        inputs.slice(:temperature, :humidity, :battery_charge).to_json
      )
    end

    def set_sum_stats
      $redis.incrbyfloat("#{household_token}.temperature_sum", temperature)
      $redis.incrbyfloat("#{household_token}.humidity_sum", humidity)
      $redis.incrbyfloat("#{household_token}.battery_charge_sum", battery_charge)
    end

    def set_min_max_stats
      $redis.set("#{household_token}.temperature_min", temperature) if $redis.get("#{household_token}.temperature_min").nil? || $redis.get("#{household_token}.temperature_min").to_f > temperature
      $redis.set("#{household_token}.temperature_max", temperature) if $redis.get("#{household_token}.temperature_max").nil? || $redis.get("#{household_token}.temperature_max").to_f < temperature
      $redis.set("#{household_token}.humidity_min", humidity) if $redis.get("#{household_token}.humidity_min").nil? || $redis.get("#{household_token}.humidity_min").to_f > humidity
      $redis.set("#{household_token}.humidity_max", humidity) if $redis.get("#{household_token}.humidity_max").nil? || $redis.get("#{household_token}.humidity_max").to_f < humidity
      $redis.set("#{household_token}.battery_charge_min", battery_charge) if $redis.get("#{household_token}.battery_charge_min").nil? || $redis.get("#{household_token}.battery_charge_min").to_f > battery_charge
      $redis.set("#{household_token}.battery_charge_max", battery_charge) if $redis.get("#{household_token}.battery_charge_max").nil? || $redis.get("#{household_token}.battery_charge_max").to_f < battery_charge
    end

    def set_sequence_number
      $redis.incr("#{household_token}.count")
    end

    def enqueue_readning_save
      SaveReadingJob.perform_later(inputs.merge(number: sequence_number))
    end

    def sequence_number
      @sequence_number ||= $redis.get("#{household_token}.count")
    end
  end
end
