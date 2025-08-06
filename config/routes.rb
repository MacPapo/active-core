Rails.application.routes.draw do
  resources :payments
  resources :discounts
  resources :packages
  resources :pricing_plans
  resources :products
  devise_for :users, path: "", path_names: { sign_in: "login", sign_out: "logout" }

  resources :users

  resources :members do
    resources :memberships, only: [ :create, :destroy ]
    resources :registrations, only: [ :create, :destroy ]
  end
  resources :memberships, only: [ :index, :edit, :update ]   # ADMIN
  resources :registrations, only: [ :index, :edit, :update ] # ADMIN

  resources :products do
    resources :pricing_plans, except: [ :index, :show ]
  end

  resources :access_grants
  resources :payments, only: [ :index, :show, :new, :create ]
  resources :receipts, only: [ :index, :show ]
  resources :reports, only: [ :show ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "members#index"
end
