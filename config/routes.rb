Rails.application.routes.draw do
  get 'sessions/new'

  get 'bases/new'

  get 'attendances/update'

  get 'users/new'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get     '/login', to: 'sessions#new'
  post    '/login', to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'
  
  #上長画面一ヶ月分勤怠申請のお知らせフォーム
  get  '/monthly_confirmation_form',    to: 'attendances#monthly_confirmation_form'
  post  '/monthly_confirmation_form',    to: 'attendances#monthly_confirmation_form'
  
  #一ヶ月分の申請
  patch  '/monthly_confirmation',    to: 'attendances#monthly_confirmation'
  
  #勤怠修正ログ
  resources :attendance_logs
  
  
  resources :users do
    collection {post :import}
    member do
      get   'edit_basic_info'
      patch 'update_basic_info'
      get   'working_employee'
      get   'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'search'
    end
    resources :attendances, only: :update
    end
    resources :bases do
  end
end