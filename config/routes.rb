# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  api_version(module: "V1", path: { value: "v1" }, default: true) do
    use_doorkeeper
  end

  namespace :api do
    namespace :internal do
      api_version(module: "V1", path: { value: "v1" }, default: true) do
        resources :prosecution_cases, only: [:index]
        resources :laa_references, only: [:create]
        resources :defendants, only: %i[update show]
        resources :representation_orders, only: [:create]
        resources :hearings, only: [:show]
      end
    end
    namespace :external do
      api_version(module: "V1", path: { value: "v1" }, default: true) do
        resources :hearings, only: [:create]
      end
    end
  end

  resources :status, only: [:index]
  get "ping", to: "status#ping", format: :json
end
