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
      get   'search'
      
      #上長画面一ヶ月分勤怠申請のお知らせフォーム
      get   'attendances/monthly_confirmation_form'
      post  'attendances/monthly_confirmation_form'
  
      #一ヶ月分の申請
      patch 'attendances/monthly_confirmation'
      patch 'attendances/monthly_update'
      
      get   'attendances/change_confirmation'
      post  'attendances/change_confirmation'
      patch 'attendances/change_confirmation'
      
      get   'attendances/change_confirmation_form'
      post  'attendances/change_confirmation_form'
      
      #残業申請送信フォーム
      get   'attendances/apply_overtime_form'
      post  'attendances/apply_overtime_form'
      patch 'attendances/apply_overtime_form'
      
      #残業申請
      get   'attendances/apply_overtime'
      post  'attendances/apply_overtime'
      patch 'attendances/apply_overtime'
      
      #残業申請のお知らせフォーム
      get   'attendances/update_overtime_form'
      post  'attendances/update_overtime_form'
      
      #残業承認
      get   'attendances/update_overtime'
      post  'attendances/update_overtime'
      patch 'attendances/update_overtime'
      
      get   'attendances/index'
      post  'attendances/index'
      patch 'attendances/index'
      
    end
    resources :attendances, only: :update
    end
    resources :bases do
  end
end