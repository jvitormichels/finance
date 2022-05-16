Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dashboard#index"

  resources :accounts do
    collection do
      get '/new', to: 'accounts#new'
      get '/:id', to: 'accounts#show'
    end
  end
end
