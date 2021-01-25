class ApiController < ActionController::API
  before_action :authenticate_thermostat!

  private

  def authenticate_thermostat!
    @thermostat = Thermostat.find_by_household_token(params[:household_token])

    render json: {}, status: 401 unless @thermostat
  end
end
