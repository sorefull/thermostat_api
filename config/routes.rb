# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resources :readings, only: %i[create show] do
      collection do
        get :stats
      end
    end
  end
end
