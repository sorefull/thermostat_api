return unless Rails.env.development?

Thermostat.delete_all
Reading.delete_all

thermostat = Thermostat.create(
  household_token: 'dummy_token',
  location: 'this is a test thermostat'
)

reading = thermostat.readings.create(
  number: '1',
  temperature: 25.3,
  humidity: 40.6,
  battery_charge: 30.0
)

$redis.set(
  thermostat.id,
  reading.attributes.slice('temperature', 'humidity', 'battery_charge').to_json
)

$redis.set('dummy_token.temperature_sum', reading.temperature)
$redis.set('dummy_token.humidity_sum', reading.humidity)
$redis.set('dummy_token.battery_charge_sum', reading.battery_charge)

$redis.set('dummy_token.temperature_min', reading.temperature)
$redis.set('dummy_token.temperature_max', reading.temperature)
$redis.set('dummy_token.humidity_min', reading.humidity)
$redis.set('dummy_token.humidity_max', reading.humidity)
$redis.set('dummy_token.battery_charge_min', reading.battery_charge)
$redis.set('dummy_token.battery_charge_max', reading.battery_charge)

$redis.set('dummy_token.count', 1)
