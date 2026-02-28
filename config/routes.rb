Rails.application.routes.draw do
  devise_for :users
  
  resources :teams, only: %i[edit update]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "pages#home"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

    # Routes grouped for admin competitions, rounds, teams
  namespace :admin do
    resources :competitions do
      resources :rounds, shallow: true
      resources :teams, shallow: true
    end
  end

  # Public routes for competitions and teams
  resources :competitions, only: [ :index, :show ]

  get "users/:id/next_match", to: "users#next_match"
  get "teams/:id/stats", to: "teams#stats"

  patch "teams/:id/upload_jersey", to: "teams#upload_jersey"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
