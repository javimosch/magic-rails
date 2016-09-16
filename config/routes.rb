Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :scores
  resources :schedules, :defaults => { :format => :json }
  resources :availabilities, :defaults => { :format => :json }
  resources :availabilities, :defaults => { :format => :json }
  resources :delivery_contents, :defaults => { :format => :json }
  resources :delivery_contents, :defaults => { :format => :json }
  resources :deliveries, :defaults => { :format => :json }
  resources :addresses, :defaults => { :format => :json }
  resources :delivery_requests, :defaults => { :format => :json }
  resources :ratings, :defaults => { :format => :json }
  resources :wallets, :defaults => { :format => :json }
  resources :notifications, :defaults => { :format => :json }
  resources :shops, :defaults => { :format => :json }
  devise_for :users, :controllers => {sessions: 'sessions', registrations: 'registrations', passwords: 'passwords'}

  post '/users/sign_in' => 'sessions#create'

  get 'orders' => 'deliveries#orders', :defaults => { :format => :json }
  post '/deliveries/:id/finalize' => 'deliveries#finalize', :defaults => { :format => :json }
  post '/deliveries/:id/confirm' => 'deliveries#confirm', :defaults => { :format => :json }
  post '/deliveries/:id/cancel' => 'deliveries#cancel', :defaults => { :format => :json }
  post '/availabilities/:id/cancel' => 'availabilities#cancel', :defaults => { :format => :json }
  
  post '/delivery_requests/:id/cancel' => 'delivery_requests#cancel', :defaults => { :format => :json }
  post '/delivery_requests/saveProducts/:id' => 'delivery_requests#saveProducts', :defaults => { :format => :json }
  post '/delivery_requests/fetchProducts/:id' => 'delivery_requests#fetchProducts', :defaults => { :format => :json }
  
  get 'products' => 'shops#products', :defaults => { :format => :json }
  get '/wallets/:id/value' => 'wallets#value', :defaults => { :format => :json }

  get 'app' => 'home#app', :defaults => { :format => :html }

  root 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
