Quails3::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  #match 'aves' => 'aves#index'

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # PUBLIC PAGES

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'posts#index'

  resources :species, :only => [:index, :show]
  resources :posts, :except => [:index, :show]

  constraints :year => /\d{4}/ do
    get '/:year' => 'posts#year', :as => 'year'
    constraints :month => /(0[1-9])|(1[0-2])/ do
      get '/:year/:month' => 'posts#month', :as => 'month'
      get '/:year/:month/:id' => 'posts#show', :as => 'show_post'
    end
  end

  get 'lifelist(/:year)(/:locus)' => 'lifelist#lifelist',
      :constraints                => {:year => /\d{4}/, :locus => /[a-z_]+/},
      :as                         => 'lifelist'

#  scope '/(:locale)', :locale => /[a-z]{2}/ do
#    resources :species, :except => [:new, :create, :destroy]
#  end


  # ADMINISTRATIVE PAGES

#  scope 'admin' do
  resources :observations
  resources :locus
  resources :species, :only => [:edit, :update]
  # end

  get 'dashboard' => 'admin#dashboard'

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end