Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Public-facing resources
  resources :users, only: %i[index show edit update], constraints: { id: /\d+/ }
  resources :competitions, only: %i[index new create show edit update]
  resources :teams, only: %i[show edit index update] do
    post :add_member, on: :member
    post :send_invite, on: :member
    patch :upload_jersey, on: :member
    patch :upload_logo, on: :member
    post :generate_logo, on: :member
    post :generate_jersey, on: :member
  end
  resources :trophies, only: %i[index new create]

  # Routes grouped for admin competitions, rounds, teams
  namespace :admin do
    resources :competitions do
      post :send_invite, on: :member
      resources :rounds, shallow: true
      resources :teams, shallow: true
    end
  end


  # Public routes for stats and next match
  get "users/:id/next_match", to: "users#next_match", constraints: { id: /\d+/ }
  get "teams/:id/stats", to: "teams#stats", constraints: { id: /\d+/ }

  # Avatar routes
  # Jersey upload CHECK IF THIS USES ACTIVE RECORD
  post   "users/avatars/generate",  to: "users/avatars#generate",  as: :generate_ai_avatar_users
  post   "users/avatars/:id/set",   to: "users/avatars#set",       as: :set_avatar
  delete "users/avatars/:id",       to: "users/avatars#destroy",   as: :delete_ai_avatar

  # ------------------------------------------------------------------------------------------
  get "invitations/accept", to: "invitations#accept", as: :accept_team_invitation
  post "/team_invitations/accept", to: "team_invitations#accept", as: "team_invitation_accept"
  post "/team_invitations/reject", to: "team_invitations#reject", as: "team_invitation_reject"

  # Root
  root "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
