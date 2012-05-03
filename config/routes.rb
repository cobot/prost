Prost::Application.routes.draw do
  root :to => 'sessions#new'

  match '/auth/:provider/callback', :to => 'sessions#create', as: :authenticate
  match '/auth/failure', :to => 'sessions#failure'

  resource :session, only: :destroy
  resources :spaces, only: [:index, :show] do
    resources :drinks, only: :create
  end
end
