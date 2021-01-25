return unless Rails.env.development?

Thermostat.delete_all
Reading.delete_all

thermostat = Thermostat.create(
  household_token: 'dummy_token',
  location: 'this is a test thermostat'
)

thermostat.readings.create(
  number: '1-123',
  temperature: 25.3,
  humidity: 60.6,
  battery_charge: 30.0
)
