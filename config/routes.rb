Rails.application.routes.draw do
  devise_for :staffs

  authenticated :staff, -> { _1.admin? } do
    resources :staffs

    resources :payments, only: [:index]
    resources :subscriptions, only: [:index]
    resources :memberships, only: [:index]
    resources :users, only: [:erase]
    resources :legal_guardians, only: [:destroy]
    resources :activities, only: %i[destroy edit]
    resources :activity_plans, only: %i[new create destory edit]

    mount MissionControl::Jobs::Engine, at: '/jobs'
  end

  resources :users, except: [:erase] do
    collection do
      get :activity_search
    end

    member do
      delete :erase
      patch :restore
    end
  end

  resources :legal_guardians, except: [:destroy] do
    collection do
      get 'find_by_email'
    end
  end

  resources :payments, except: [:index]

  resources :activities, except: %i[destroy edit] do
    get 'plans', on: :member
    get 'name', on: :member
  end

  resources :activity_plans, except: %i[new create destory edit]

  resources :waitlists, except: %i[index show]
  get 'receipt/show'

  resources :daily_cash

  resources :memberships, except: [:index] do
    member do
      get   :renew
      patch :renew_update
    end
  end

  resources :subscriptions, except: [:index] do
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
