Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check
  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
  # Defines the root path route ("/")
  # root "posts#index"

  scope "v1", module: "api/v1" do
    resources :auth, only: [] do
      collection do
        post "/login" => "auth#login"
        get "/logout" => "auth#logout"
      end
    end

    resources :report, only: [] do
      collection do
        get "/lps" => "report#lps"
      end
    end

    resources :artists, only: %i[index show create update destroy]
    resources :lps, only: %i[index show create update destroy]
  end
end
