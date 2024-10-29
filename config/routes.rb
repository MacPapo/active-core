Rails.application.routes.draw do
  devise_for :staffs

  unauthenticated do
    as :staff do
      root to: 'devise/sessions#new', as: :login
    end
  end

  authenticate do
    resources :users do
      collection do
        get :activity_search
      end

      member do
        patch :restore
      end
    end

    resources :daily_cash
    resources :receipts, only: [:show]
    resources :waitlists

    authenticated :staff, -> { !_1.admin? } do
      resources :legal_guardians, except: [:destroy] do
        collection do
          get 'find_by_email'
        end
      end

      resources :activities, except: %i[new edit update create destory restore] do
        member do
          get 'plans'
          get 'name'
          patch :restore
        end
      end

      resources :activity_plans, except: %i[new edit create destory]

      resources :payments, except: [:index]

      resources :memberships, except: [:index] do
        member do
          get   :renew
          patch :renew_update
          patch :restore
        end
      end

      resources :subscriptions, except: [:index] do
        member do
          get   :renew
          patch :renew_update
          patch :restore
        end
      end
    end

    # Only for authenticated ADMIN!
    authenticated :staff, -> { _1.admin? } do
      resources :staffs
      resources :legal_guardians do
        collection do
          get 'find_by_email'
        end
      end
      resources :activities do
        member do
          get 'plans'
          get 'name'
          patch :restore
        end
      end
      resources :activity_plans
      resources :payments

      resources :memberships do
        member do
          get   :renew
          patch :renew_update
          patch :restore
        end
      end

      resources :subscriptions do
        member do
          get   :renew
          patch :renew_update
          patch :restore
        end
      end

      mount MissionControl::Jobs::Engine, at: '/jobs'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root to: 'users#index'
end
