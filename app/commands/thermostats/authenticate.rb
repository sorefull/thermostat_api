module Thermostats
  class Authenticate < Mutations::Command
    required do
      string :household_token
    end

    def execute
      return true if $redis.get(household_token)

      if Thermostat.find_by_household_token(household_token).present?
        $redis.set(household_token, true)
        return true
      end

      false
    end
  end
end
