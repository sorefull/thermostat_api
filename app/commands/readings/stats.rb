module Readings
  class Create < Mutations::Command
    required do
      integer :thermostat_id
    end

    def execute
      {
        avg_temperature: $redis.get("#{thermostat_id}.temperature_sum") / sequence_number,
        min_temperature: $redis.get("#{thermostat_id}.temperature_min"),
        max_temperature: $redis.get("#{thermostat_id}.temperature_max"),
        avg_humidity: $redis.get("#{thermostat_id}.humidity_sum") / sequence_number,
        min_humidity: $redis.get("#{thermostat_id}.humidity_min"),
        max_humidity: $redis.get("#{thermostat_id}.humidity_max"),
        avg_battery_charge: $redis.get("#{thermostat_id}.battery_charge_sum") / sequence_number,
        min_battery_charge: $redis.get("#{thermostat_id}.battery_charge_min"),
        max_battery_charge: $redis.get("#{thermostat_id}.battery_charge_max")
      }
    end

    private

    def sequence_number
      @sequence_number =|| $redis.get("#{thermostat_id}.count")
    end
  end
end
