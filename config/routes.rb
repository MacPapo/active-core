Rails.application.routes.draw do
  devise_for :staffs
  resources :waitlists

  authenticated :staff, -> { _1.admin? } do
    # TODO delete this
    resources :membership_histories
    resources :subscription_histories
  end

  resources :memberships
  resources :legal_guardians
  resources :payments
  resources :staffs
  resources :activities
  resources :activity_plans
  resources :users

  resources :subscriptions do
    member do
      get   :renew
      patch :renew_update
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "users#index"
end
