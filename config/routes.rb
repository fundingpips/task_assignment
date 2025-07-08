# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [] do
      resources :ip_activities, only: [:index], module: :users do
        collection do
          get :filter_metadata
        end
      end
    end
  end
end
