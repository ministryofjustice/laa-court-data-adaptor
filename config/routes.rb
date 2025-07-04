# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  mount Sidekiq::Web => "/sidekiq"

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
        resources :prosecution_case_laa_references, path: "laa_references", only: %i[create]
        resources :defendants, only: %i[update show]
        resources :prosecution_case_representation_orders, path: "representation_orders", only: [:create]
        resources :court_application_representation_orders, only: [:create]
        resources :hearing_results, path: "hearings", only: [:show]
      end

      api_version(module: "V2", path: { value: "v2" }) do
        resources :court_applications, only: [:show]
        resources :prosecution_cases, only: [:index], param: :reference do
          resources :defendants, only: %i[show] do
            member { get :offence_history }
          end
          collection { post "/", to: "index" }
        end
        resources :prosecution_case_laa_references, path: "laa_references", only: %i[create update], param: :defendant_id
        resources :court_application_laa_references, only: %i[create update], param: :subject_id
        resources :prosecution_case_representation_orders, path: "representation_orders", only: [:create]
        resources :hearing_results, only: [:show], param: :hearing_id
        get "hearings/:hearing_id/event_log/:hearing_date", to: "hearing_event_logs#show"
        resources :hearing_repull_batches, only: %i[create show]
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
