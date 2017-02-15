SpreeVendorMarketplace.routes.draw do

	 
  namespace :merchant do
    get "stores/amazon/fetch", to: "amazon_products#fetch", as: "store_amazon_product"
    get "/", to: "home#index"
    get "stores/products/:product_id/variants", to: "variants#index", as: "stores_products_variants"
    get "stores/products/:product_id/variants/new", to: "variants#new", as: "stores_products_variants_new"
    get "stores/:store_id/orders", to: "orders#index", as: :store_orders
    
    resources :stores do
      collection do
        resources :amazon_products do
          collection do
            post :import_collection
          end
        end 
        resources :products do
          resources :images
          resources :variants
          resources :product_properties
          get :stock
          collection do
            post :bulk_upload
            get :sample_csv
          end
        end
        resources :orders do
          get :customer
          get :adjustments
          get :payments
          get :approve
          put :cancel
          post :return_item_accept_reject
          resources :customer_return_items do 
            collection do
              get :eligible_item
              post :return_multiple_item
            end
          end
          collection do 
            get :returns
          end
        end
      end
    end
    resources :products
    resources :return_authorization_reasons
  end

end