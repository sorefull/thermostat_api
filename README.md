# Thermostat API

This is a code challenge.

The `Thermostat API` application is api only rails application that is used for saving and providing information collected from IoT thermostats.

### Configuration

This application is dockerised, it means that to run it you will only need to have [docker](https://www.docker.com/) and to run `docker-compose up` in the application folder.

This will start several applications inside of your docker:
- `web` - rails api application
- `redis` - an instance to store all redis related data
- `sidekicq` - runs a worker and an interface
- `postgress` - a database instance

### Usage

The `Thermostat API` application provides 3 endpoints.

To use `Thermostat API` you will need to:
- create a database - `docker-compose run web rails db:setup`
- to seed it with some default data - `docker-compose run web rails db:seed`
- start the application - `docker-compose up`

```bash
# Saving a reading
curl -d '{"temperature":"30.1", "humidity":"30.0", "battery_charge":"40.0"}' -H "Content-Type: application/json" -X POST 'http://127.0.0.1:3000/api/readings?household_token=dummy_token'
# Response example: {"number":"2"}
```

```bash
# Successful fetching a reading
curl -XGET 'http://127.0.0.1:3000/api/readings/1?household_token=dummy_token'
# Response example: {"temperature":30.1,"humidity":30.0,"battery_charge":40.0}
```

```bash
# Unsuccessful fetching a reading
curl -XGET 'http://127.0.0.1:3000/api/readings/xxx?household_token=dummy_token'
# Will return you an error: {"reading":"not found"}
```

```bash
# Fetching stats
curl -XGET 'http://127.0.0.1:3000/api/readings/stats?household_token=dummy_token'
# Response example {"avg_temperature":28.9,"min_temperature":25.3,"max_temperature":30.1,"avg_humidity":32.65,"min_humidity":30.0,"max_humidity":40.6,"avg_battery_charge":37.5,"min_battery_charge":30.0,"max_battery_charge":40.0}
```

### Testing

To run tests you will only need to execute `docker-compose up test`

### Room for improvement

Since this project is just a code challenge it does not solve all issues. Before using it in the production this issues should be taken care of:

- assuming unreliability of `redis`, taking care of `count` desynchronisation
- authentication for `sidekicq`
- add number validation for `reading`
