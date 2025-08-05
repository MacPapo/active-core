Rails.application.routes.draw do
  # devise_for :staffs

  # unauthenticated do
  #   as :staff do
  #     root to: "devise/sessions#new", as: :login
  #   end
  # end

  # authenticate do
  #   resources :users do
  #     collection do
  #       get :activity_search
  #     end

  #     member do
  #       patch :restore
  #     end
  #   end

  #   resources :daily_cash
  #   resources :receipts, only: [ :show ]
  #   resources :waitlists

  #   authenticated :staff, -> { !_1.admin? } do
  #     resources :legal_guardians, except: [ :destroy ] do
  #       collection do
  #         get "find_by_email"
  #       end
  #     end

  #     # Removed restore
  #     resources :activities, except: %i[new edit update create destroy] do
  #       member do
  #         get "plans"
  #         get "name"
  #         patch :restore
  #       end
  #     end

  #     resources :activity_plans, except: %i[new edit create destroy]

  #     resources :payments, except: [ :index ]

  #     resources :memberships, except: [ :index ] do
  #       member do
  #         get   :renew
  #         patch :renew_update
  #         patch :restore
  #       end
  #     end

  #     resources :subscriptions, except: [ :index ] do
  #       member do
  #         get   :renew
  #         patch :renew_update
  #         patch :restore
  #       end
  #     end
  #   end

  #   # Only for authenticated ADMIN!
  #   authenticated :staff, -> { _1.admin? } do
  #     resources :staffs do
  #       member do
  #         patch :restore
  #       end
  #     end

  #     resources :legal_guardians do
  #       collection do
  #         get "find_by_email"
  #       end
  #     end

  #     resources :activities do
  #       member do
  #         get "plans"
  #         get "name"
  #         patch :restore
  #       end
  #     end

  #     resources :activity_plans do
  #       member do
  #         patch :restore
  #       end
  #     end

  #     resources :payments do
  #       member do
  #         patch :restore
  #       end
  #     end

  #     resources :memberships do
  #       member do
  #         get   :renew
  #         patch :renew_update
  #         patch :restore
  #       end
  #     end

  #     resources :subscriptions do
  #       member do
  #         get   :renew
  #         patch :renew_update
  #         patch :restore
  #       end
  #     end
  #   end
  # end

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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "members#index"
end
