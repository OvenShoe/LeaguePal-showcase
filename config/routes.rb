Rails.application.routes.draw do
  devise_for :users
  resources :users, only: %i[index show edit update], constraints: { id: /\d+/ }
  resources :competitions, only: %i[index new create show edit update]
  resources :teams, only: %i[edit update]
  resources :trophies, only: %i[index new create]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "pages#home"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "users/:id/next_match", to: "users#next_match", constraints: { id: /\d+/ }
  get "teams/:id/stats", to: "teams#stats", constraints: { id: /\d+/ }

  patch "teams/:id/upload_jersey", to: "teams#upload_jersey", constraints: { id: /\d+/ }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
