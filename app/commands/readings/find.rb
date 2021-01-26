module Readings
  class Find < Mutations::Command
    required do
      string :number
      string :household_token
    end

    def execute
      if number == sequence_number
        get_reading_stats_from_redis
      else
        get_reading_stats_from_database
      end
    end

    private

    def get_reading_stats_from_redis
      $redis.get(household_token)
    end

    def get_reading_stats_from_database
      thermostat = Thermostat.find_by_household_token(household_token)
                             .readings
                             .find_by_number(number)

      return { reading: 'not found' }.to_json unless thermostat

      thermostat.attributes
                .slice('temperature', 'humidity', 'battery_charge')
                .to_json
    end

    def sequence_number
      $redis.get("#{household_token}.count")
    end
  end
end
