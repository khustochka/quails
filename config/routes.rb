Quails::Application.routes.draw do
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
  root to: 'blog#front_page', as: 'blog'

  constraints country: /ukraine|usa/ do
    get '/:country' => 'countries#gallery', as: "country"
    get '/:country/checklist' => 'checklist#show', as: "checklist"
    get '/:country/checklist/edit' => 'checklist#edit'
    post '/:country/checklist/edit' => 'checklist#save'
  end

  get '/species' => 'species#gallery', as: 'gallery'
  resources :species, only: [:show] do
    collection do
      get 'admin', action: :index
    end
  end

  get '/photos(/page/:page)' => 'images#index', page: /[^0]\d*/, constraints: {format: 'html'}
  get '/photos/various' => 'images#various'
  resources :photos, controller: 'images', as: 'images', except: :index do
    member do
      get 'edit/map', action: :map_edit
      get 'edit/flickr', action: :flickr_edit
      post 'patch'
      get 'observations'
    end
    collection do
      get 'add'
      get 'flickr_search'
    end
  end

  constraints year: /20\d\d/ do
    get '/:year' => 'blog#year', as: 'year'
    constraints month: /(0[1-9])|(1[0-2])/ do
      get '/:year/:month' => 'blog#month', as: 'month'
      get '/:year/:month/:id' => 'posts#show', as: 'show_post'
    end
  end

  get '/archive' => 'blog#archive'

  get '/my' => 'my_stats#index', as: :my_stats

  get '/my/lists' => 'lists#index'

  get '/my/lists/advanced' => 'lists#advanced', as: :advanced_list

  get '/my/lists/life(/:sort)' => 'lists#basic', as: :lifelist

  get '/my/lists(/:locus)(/:year)(/:sort)' => 'lists#basic', as: :list,
      locus: /(?!by_)\D[^\/]+/, # negative look-ahead: not starting with 'by_'
      year: /\d{4}/,
      sort: /by_taxonomy/

  # Static pages
  get '/:id' => 'pages#show', constraints: {id: /links|about/}, as: :page

  # Feeds and sitemap
  get '/blog.:format' => 'feeds#blog', constraints: {format: 'xml'}
  get '/photos.:format' => 'feeds#photos', constraints: {format: 'xml'}
  get '/sitemap.:format' => 'feeds#sitemap', constraints: {format: 'xml'}

#  scope '/(:locale)', locale: /[a-z]{2}/ do
#    resources :species, except: [:new, :create, :destroy]
#  end

# ADMINISTRATIVE PAGES

  resources :posts, except: [:index, :show] do
    get :hidden, on: :collection
    post :lj_post, on: :member
  end

  resources :observations do
    collection do
      get 'search(/:with_spots)', action: :search, with_spots: /with_spots/
      get 'add'
      get 'bulk'
      post 'bulksave'
    end
  end

  resources :loci do
    collection do
      get :public
      post :save_order
    end
  end

  resources :species, only: [:edit, :update] do
    member do
      get 'review'
    end
  end

  resources :comments, except: :new do
    get :reply, on: :member
  end

  resource :map, only: [:show, :edit] do
    resources :spots, only: :index
  end

  resources :spots, only: :destroy do
    post :save, on: :collection
  end

  resources :books do
    resources :taxa, only: [:show, :update]
  end
  get '/books/:id/taxa' => redirect("/books/%{id}")

  get '/settings' => 'settings#index'
  post '/settings/save' => 'settings#save'

  get '/research(/:action)', controller: :research, as: :research

  get '/login' => 'login#login'

  get '/flickr' => 'flickr#search'
  get '/flickr/auth' => 'flickr#auth'


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
