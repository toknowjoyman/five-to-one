Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 get 'dashboard/index'
 root 'dashboard#index'
 resources :to_do_items
 # get 'to_do_items/new'
 # get 'to_do_items/list'

end
