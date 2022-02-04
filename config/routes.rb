# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  api_version(module: "V1", path: { value: "v1" }, default: true) do
    use_doorkeeper
  end

  api_version(module: "V2", path: { value: "v2" }) do
    use_doorkeeper
  end

  namespace :api do
    namespace :internal do
      api_version(module: "V1", path: { value: "v1" }, default: true) do
        resources :prosecution_cases, only: [:index]
        resources :laa_references, only: %i[create destroy], param: :defendant_id
        resources :defendants, only: %i[update show]
        resources :representation_orders, only: [:create]
        resources :hearing_results, path: "hearings", only: [:show]
      end

      api_version(module: "V2", path: { value: "v2" }) do
        resources :prosecution_cases, only: [:index]
        resources :laa_references, only: %i[create update], param: :defendant_id
        resources :defendants, only: %i[update show]
        resources :representation_orders, only: [:create]
        resources :hearing_results, only: [:show]
      end
    end

    namespace :external do
      api_version(module: "V1", path: { value: "v1" }, default: true) do
        resources :hearing_results, path: "hearings", only: [:create]
        resources :prosecution_conclusions, only: [:create]
      end

      api_version(module: "V2", path: { value: "v2" }) do
        resources :hearing_results, only: [:create]
        resources :prosecution_conclusions, only: [:create]
      end
    end
  end

  resources :status, only: [:index]
  get "ping", to: "status#ping", format: :json
end
