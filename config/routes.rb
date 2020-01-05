Rails.application.routes.draw do
  get 'bases/new'

  get 'attendances/update'

  get 'users/new'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get     '/login', to: 'sessions#new'
  post    '/login', to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'
  
  
  resources :users do
    member do
      get   'edit_basic_info'
      patch 'update_basic_info'
      get   'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
    end
    resources :attendances, only: :update
  end
end