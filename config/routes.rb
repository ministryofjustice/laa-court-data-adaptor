# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper
  namespace :api do
    namespace :internal do
      api_version(module: 'V1', path: { value: 'v1' }, default: true) do
        resources :prosecution_cases, only: [:index]
      end
    end
    namespace :external do
      api_version(module: 'V1', path: { value: 'v1' }, default: true) do
        resources :hearings, only: [:create]
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :status, only: [:index]
end
