Rails.application.routes.draw do
  # Authentication
  get    "login"  => "sessions#new", as: :login
  post   "login"  => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout

  get  "signup" => "registrations#new", as: :signup
  post "signup" => "registrations#create"

  # Theme switching
  patch "theme" => "themes#update", as: :update_theme

  # Dashboard
  get "dashboard" => "dashboard#show", as: :dashboard

  # AI Harnesses — global dashboard
  get "harnesses" => "ai_integrations#global", as: :ai_harnesses
  post "harnesses/discover" => "ai_integrations#discover", as: :discover_harnesses
  get "harnesses/:harness_type/fields" => "ai_integrations#harness_fields", as: :harness_fields

  # Projects
  resources :projects do
    # Journal entries nested under projects
    resources :journal_entries, as: :entries, path: :journal, except: [:index] do
      collection do
        get :search
      end
    end

    # Assets nested under projects
    resources :assets, except: [:index]

    # AI integrations nested under projects
    resources :ai_integrations do
      member do
        post :check
        post :launch
      end
    end
  end

  # Standalone journal browsing
  resources :journal_entries, only: [:index], as: :all_entries, path: "/journal"

  # Global settings
  resource :settings, only: [:show, :update]

  # Root
  root "dashboard#show"
end
