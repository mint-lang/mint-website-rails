Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sandbox#login'

  resources :sandbox do
    collection do
      get :recent
      get :user
    end

    member do
      post :fork
      post :format
    end
  end
end
