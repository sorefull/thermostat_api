# frozen_string_literal: true

module Thermostats
  # This class is used in ApiController
  class Authenticate < Mutations::Command
    required do
      string :household_token
    end

    def execute
      return true if Rails.configuration.redis.get(household_token)

      if Thermostat.find_by_household_token(household_token).present?
        Rails.configuration.redis.set(household_token, true)
        return true
      end

      false
    end
  end
end
