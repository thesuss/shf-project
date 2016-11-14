Rails.application.routes.draw do

  devise_for :users
  root to: 'application#index.html'
  resources :memberships, only: [:new, :create, :edit, :update, :index, :show] do
    patch 'update_status', controller: :memberships, action: :update_status
    get 'manage', controller: :memberships, action: :manage
  end


end
