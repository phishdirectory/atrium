# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # User registration
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy"
  delete "logout", to: "sessions#destroy"

  # Session management
  resources :sessions, only: [:destroy]
  delete "sessions", to: "sessions#destroy_all", as: "sign_out_all_sessions"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount OkComputer::Engine, at: "ok"

  constraints AdminConstraint.new do
    namespace :admin do
      mount MissionControl::Jobs::Engine, at: "/jobs"
      mount Audits1984::Engine => "/console"
      mount Flipper::UI.app(Flipper), at: "/flipper"
      mount Blazer::Engine, at: "/blazer"
    end
  end

  # # Fallback redirect if adminconstraint fails
  get "admin/*path", to: redirect("/login")



  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#index"

end
