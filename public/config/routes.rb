Rails.application.routes.draw do
  get 'charge/new'

  #mount_devise_token_auth_for 'User', at: 'api/auth'
  scope '/api' do
    mount_devise_token_auth_for 'User', at: '/auth'
    resources :groups, except: [:new, :edit]
  end


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


  namespace :api do
    resources :stores

    resources :orders do
      collection do
        get 'stats'
        get 'billing_stats'
      end

      member do
        get 'source_order'
        get 'order_details'
      end

      # notes and order_line_items are nested within orders
      resources :notes
      resources :order_line_items, only: [:index, :show, :edit, :update]
    end

    # customers will charge some money on this platform.
    resources :charge do
      collection do
        get 'card_info'
      end
    end

    resources :printers
    resources :master_product_types
    resources :products
    resources :listings, except: [:edit, :update]
    resources :shops

    # for users, creation must still be done through devise
    resources :users, only: [:index, :show, :edit, :update, :destroy]

    # for MasterProducts, it is read only
    resources :master_products, only: [:index, :show, :update]

    # resources :customers

  end

end
