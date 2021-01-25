module Readings
  class Find < Mutations::Command
    required do
      integer :number
      integer :household_token
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
      $redis.get(thermostat_id)
    end

    def get_reading_stats_from_database
      Thermostat.find_by_household_token(household_token)
                .readings
                .find_by_number(number)
                .attributes
                .slice(:temperature, :humidity, :battery_charge)
                .to_json
    end

    def sequence_number
      $redis.get("#{thermostat_id}.count")
    end

    def thermostat_id
      @thermostat_id =|| Thermostat.find_by_household_token(household_token).id
    end
  end
end
