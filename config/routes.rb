# config/routes.rb
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

  # Email routes
  resources :emails do
    member do
      patch :mark_read
      patch :mark_unread
      patch :star
      patch :unstar
      patch :archive
      patch :unarchive
    end
    collection do
      get :inbox
      get :sent
      get :starred
      get :archived
    end
  end

  # Action Mailbox
  mount ActionMailbox::Engine => "/action_mailbox"

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

  # Fallback redirect if adminconstraint fails
  get "admin/*path", to: redirect("/login")

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Defines the root path route ("/")
  root "emails#index"
end
