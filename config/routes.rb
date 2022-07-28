Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dashboard#index"

  resources :accounts do
    collection do
      get '/new', to: 'accounts#new'
      get '/:id', to: 'accounts#show'
      post '/new', to: 'accounts#create'
      post '/:id/update', to: 'accounts#update'
      # delete '/destroy/:id', to: 'accounts#destroy'
    end
  end

  resources :entries, only: [:index, :show, :new, :create, :edit, :destroy]
  resources :entries do
    collection do
      post '/:id/update', to: 'entries#update'
    end
  end

  resources :categories do
    collection do
      post '/:id/update', to: 'categories#update'
    end
  end

  resources :installments, only: [:index, :show, :new, :create, :edit, :destroy]
  resources :installments do
    collection do
      post '/:id/update', to: 'installments#update'
    end
  end
end
