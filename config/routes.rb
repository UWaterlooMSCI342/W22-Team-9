Rails.application.routes.draw do
  resources :reports

  resources :teams

  resources :feedbacks
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get 'team_view/help', to: 'teams#help'
  get 'regenerate_admin_code', to: 'options#regenerate_admin_code'
  get 'reset_password', to: 'static_pages#show_reset_password'
  post 'reset_password', to: 'static_pages#reset_password'
        
  get 'teams/:id/confirm_delete_user_from_team', to: 'teams#confirm_delete_user_from_team', as: 'team_confirm_delete_delete_user_from_team'  
  get 'teams/:id/confirm_delete', to: 'teams#confirm_delete', as: 'team_confirm_delete'
  get 'teams/:id/show_in_depth', to: 'teams#show_in_depth', as: 'team_show_in_depth'

  resources :teams 
  
  get 'users/:id/confirm_delete', to: 'users#confirm_delete', as: 'user_confirm_delete'
  
  get    '/login',  to: 'sessions#new'    
  post   '/login',  to: 'sessions#create'    
  get    '/logout', to: 'sessions#destroy' 
  get '/signup', to: 'users#new'

  get 'users/:id/generate_password', to:'users#generate_password', as: 'user_regenerate_password'
  
  resources :users, except: [:new]
  resources :options do
    post :toggle_reports
  end  
  resources :teams do
    post :remove_user_from_team
  end  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end


