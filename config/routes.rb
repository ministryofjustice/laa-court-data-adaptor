# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :status, only: [:index]
  resources :hearings, only: [:create]
  resources :prosecution_cases, only: [:index]
end
