class ApiController < ActionController::API
  before_action :authenticate_thermostat!

  private

  def authenticate_thermostat!
    outcome = Thermostats::Authenticate.run(authenticate_params)

    render json: {}, status: 401 unless outcome.success?
  end

  def authenticate_params
    params.permit(:household_token)
  end
end
