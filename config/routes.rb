Rails.application.routes.draw do
  resources :orders
  namespace :api do
    resources :meli_notifications, only: [ :create ]
  end

  resource :session
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :products do
    resources :subscribers, only: [ :create ]
  end

  resources :tax_accounts, only: %i[ new create ]

  resources :meli_notifications, only: [ :index ]

  resource :unsubscribe, only: [ :show ]

  get "meli_connections/new"
  get "meli_connections/authorize"
  delete "meli_connections/:id", to: "meli_connections#destroy", as: "destroy_meli_connection"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
