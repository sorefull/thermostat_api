module Readings
  class Create < Mutations::Command
    required do
      float :temperature
      float :humidity
      float :battery_charge
      integer :thermostat_id
      integer :household_token
    end

    def execute
      set_reading_stats
      set_sum_stats
      set_min_max_stats

      enqueue_readning_save

      sequence_number
    end

    private

    def set_reading_stats
      $redis.set(
        thermostat_id,
        inputs.slice(:temperature, :humidity, :battery_charge).to_json
      )
    end

    def set_sum_stats
      $redis.incrby("#{thermostat_id}.temperature_sum", temperature)
      $redis.incrby("#{thermostat_id}.humidity_sum", humidity)
      $redis.incrby("#{thermostat_id}.battery_charge_sum", battery_charge)
    end

    def set_min_max_stats
      $redis.set("#{thermostat_id}.temperature_min") if $redis.get("#{thermostat_id}.temperature_min").to_f > temperature
      $redis.set("#{thermostat_id}.temperature_max") if $redis.get("#{thermostat_id}.temperature_max").to_f < temperature
      $redis.set("#{thermostat_id}.humidity_min") if $redis.get("#{thermostat_id}.humidity_min").to_f > humidity
      $redis.set("#{thermostat_id}.humidity_max") if $redis.get("#{thermostat_id}.humidity_max").to_f < humidity
      $redis.set("#{thermostat_id}.battery_charge_min") if $redis.get("#{thermostat_id}.battery_charge_min").to_f > battery_charge
      $redis.set("#{thermostat_id}.battery_charge_max") if $redis.get("#{thermostat_id}.battery_charge_max").to_f < battery_charge
    end

    def set_sequence_number
      $redis.incr("#{thermostat_id}.count")
    end

    def enqueue_readning_save
      SaveReadingJob.perform_later(inputs.merge(number: sequence_number))
    end

    def sequence_number
      @sequence_number =|| $redis.get("#{thermostat_id}.count")
    end
  end
end
