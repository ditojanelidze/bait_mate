Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication - Registration
  get "register", to: "registrations#new", as: :new_registration
  post "register", to: "registrations#create", as: :registration
  get "register/verify", to: "registrations#verify", as: :verify_registration
  post "register/confirm", to: "registrations#confirm", as: :confirm_registration
  post "register/resend", to: "registrations#resend_code", as: :resend_registration_code

  # Authentication - Sessions (Login)
  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create", as: :session
  get "login/verify", to: "sessions#verify", as: :verify_session
  post "login/confirm", to: "sessions#confirm", as: :confirm_session
  post "login/resend", to: "sessions#resend_code", as: :resend_session_code
  delete "logout", to: "sessions#destroy", as: :logout

  # Profile (own profile)
  get "profile", to: "profiles#show", as: :profile

  # Settings
  get "settings", to: "settings#index", as: :settings
  get "profile/edit", to: "profiles#edit", as: :edit_profile
  patch "profile", to: "profiles#update", as: :update_profile

  # Notifications
  resources :notifications, only: [ :index ] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end

  # Users (public profiles)
  resources :users, only: [ :show ] do
    resource :follow, only: [ :create, :destroy ]
    member do
      get :followers
      get :following
    end
  end

  # Map
  get "map", to: "map#index", as: :map
  get "map/water_bodies", to: "map#water_bodies", as: :map_water_bodies

  # Posts (News Feed)
  resources :posts do
    resources :comments, only: [:index, :create, :destroy] do
      collection do
        get :modal
        get :more
      end
    end
    resource :like, only: [:create, :destroy] do
      get :likers, on: :collection
    end
  end

  # Root path - News Feed
  root "posts#index"
end
