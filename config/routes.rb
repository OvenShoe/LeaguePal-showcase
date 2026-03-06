Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Public-facing resources
  resources :users, only: %i[index show edit update], constraints: { id: /\d+/ }
  resources :competitions, only: %i[index new create show edit update]
  resources :teams, only: %i[show edit update] do
     post :add_member, on: :member
  end
  resources :trophies, only: %i[index new create]

  # Routes grouped for admin competitions, rounds, teams
  namespace :admin do
    resources :competitions do
      resources :rounds, shallow: true
      resources :teams, shallow: true
    end
  end

  # Public routes for stats and next match
  get "users/:id/next_match", to: "users#next_match", constraints: { id: /\d+/ }
  get "teams/:id/stats", to: "teams#stats", constraints: { id: /\d+/ }

  # Jersey upload CHECK IF THIS USES ACTIVE RECORD
  patch "teams/:id/upload_jersey", to: "teams#upload_jersey", constraints: { id: /\d+/ }
  # ------------------------------------------------------------------------------------------
  get "users/:id/next_match", to: "users#next_match"
  get "teams/:id/stats", to: "teams#stats"
  get "invitations/accept", to: "invitations#accept", as: :accept_team_invitation
  post "competitions/:id/send_invite", to: "competitions#send_invite", as: :send_competition_invite


  # Root
  root "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
