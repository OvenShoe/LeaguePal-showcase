Rails.application.routes.draw do
  devise_for :users

  # Public-facing resources
  resources :users, only: %i[index show edit update], constraints: { id: /\d+/ }
  resources :competitions, only: %i[index new create show edit update]
  resources :teams, only: %i[edit update]
  resources :trophies, only: %i[index new create]

  # Admin namespace (incoming changes)
  namespace :admin do
    resources :competitions do
      resources :rounds, shallow: true
      resources :teams, shallow: true
    end
  end

  # Public routes for stats and next match
  get "users/:id/next_match", to: "users#next_match", constraints: { id: /\d+/ }
  get "teams/:id/stats", to: "teams#stats", constraints: { id: /\d+/ }

  # Jersey upload
  patch "teams/:id/upload_jersey", to: "teams#upload_jersey", constraints: { id: /\d+/ }

  # Root
  root "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
