Rails.application.routes.draw do

  devise_for :users
  root to: 'application#index.html'
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show] do
    patch 'update_status', controller: :membership_applications, action: :update_status
  end

end
