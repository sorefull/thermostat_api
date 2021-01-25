module Api
  class ReadingsController < ApiController
    def create
      outcome = Readings::Create.run(reading_params)

      if outcome.success?
        render json: { number: outcome.result }
      else
        render json: { errors: outcome.errors }
      end
    end

    def show
      outcome = Readings::Find.run(reading_params.merge(number: params[:id]))

      if outcome.success?
        render json: outcome.result
      else
        render json: { errors: outcome.errors }
      end
    end

    def stats
      outcome = Readings::Stats.run(reading_params)

      if outcome.success?
        render json: outcome.result
      else
        render json: { errors: outcome.errors }
      end
    end

    private

    def reading_params
      params.permit(:battery_charge, :humidity, :temperature, :thermostat_id, :household_token)
    end
  end
end
