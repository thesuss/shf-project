Rails.application.routes.draw do

  devise_for :users
  root to: 'companies#index'

  resources :business_categories
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show]
  resources :companies, only: [:new, :create, :edit, :update, :index, :show]

  get 'information', to: 'membership_applications#information'
end
