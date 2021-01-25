Rails.application.routes.draw do
  namespace :api do
    resources :readings, only: %i(create show) do
      member do
        get :stats
      end
    end
  end
end
