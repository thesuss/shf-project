Rails.application.routes.draw do

  devise_for :users
  root to: 'application#index.html'
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show]
  resources :admin, only: [:index]
  namespace 'admin' do
    get 'list-applications', to: 'admin#show_membership_applications'
  end
end
