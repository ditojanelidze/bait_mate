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

  # Profile
  get "profile", to: "profiles#show", as: :profile
  get "profile/edit", to: "profiles#edit", as: :edit_profile
  patch "profile", to: "profiles#update", as: :update_profile

  # Posts (News Feed)
  resources :posts do
    resources :comments, only: [:index, :create, :destroy]
    resource :like, only: [:create, :destroy]
  end

  # Root path - News Feed
  root "posts#index"
end
