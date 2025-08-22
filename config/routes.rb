# frozen_string_literal: true

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'application#index'
  resources :conversations, only: %i[show create destroy]
  resources :messages, only: %i[create]
end
