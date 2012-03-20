Quails3::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # PUBLIC PAGES

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'blog#index', as: 'blog'

  resources :species, only: [:index, :show]
  resources :posts, except: [:index, :show]

  # Constraint below is to differ paths like /species/Crex_crex/edit from /species/Crex_crex/photo-of-the-corncrake
  get 'species/:species/:id' => 'images#show', as: 'show_image', constraints: lambda { |r| r.url !~ /edit$/ }
  get 'photostream' => 'images#photostream'

  constraints year: /(19|20)\d\d/ do
    get '/:year' => 'blog#year', as: 'year'
    constraints month: /(0[1-9])|(1[0-2])/ do
      get '/:year/:month' => 'blog#month', as: 'month'
      get '/:year/:month/:id' => 'posts#show', as: 'show_post'
    end
  end

  get 'lifelist(/:year)(/:locus)(/:sort)' => 'lifelist#default', as: :lifelist,
      year: /\d{4}/,
      locus: /(?!by_)[^\/]+/, # negative look-ahead: not starting with 'by_'
      sort: /by_(count|taxonomy)/

  get 'blog.:format' => 'feeds#blog', constraints: {format: 'xml'}

#  scope '/(:locale)', locale: /[a-z]{2}/ do
#    resources :species, except: [:new, :create, :destroy]
#  end


# ADMINISTRATIVE PAGES

# scope 'admin' do
  resources :observations do
    collection do
      get 'search'
      get 'add'
      get 'bulk'
      post 'bulksave'
    end
  end
  resources :loci
  resources :species, only: [:edit, :update]
  resources :images, except: :show do
    get 'observations', on: :member
    get 'flickr_search', on: :collection
  end
  resources :comments, except: :new do
    get :reply, on: :member
  end
# end

  resource :map, only: [:show, :edit] do
    resources :spots, only: :index do
      collection do
        get :search
        post :save
      end
    end
  end

  get 'research(/:action)', controller: :research, as: :research

  get 'login' => 'login#login'

  get 'flickr' => 'flickr#search'
  get 'flickr/auth' => 'flickr#auth'

  # LEGACY REDIRECTS

  # The captured wildcard in a Rails 3 route can be used in the redirect method:
  # match 'via/:source' => redirect('/?utm_source=%{source}')

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
  # match ':controller(/:action(/:id))(.:format)'
end
