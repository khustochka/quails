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
  root to: 'blog#front_page', as: 'blog'

  resources :species, only: [:index, :show]

  # Constraint below is to differ paths like /species/Crex_crex/edit from /species/Crex_crex/photo-of-the-corncrake
  get '/species/:species/:id' => 'images#show', as: 'show_image', constraints: lambda { |r| r.url !~ /edit$/ }
  get '/photostream(/page/:page)' => 'images#photostream', as: 'photostream', page: /[^0]\d*/

  constraints year: /20\d\d/ do
    get '/:year' => 'blog#year', as: 'year'
    constraints month: /(0[1-9])|(1[0-2])/ do
      get '/:year/:month' => 'blog#month', as: 'month'
      get '/:year/:month/:id' => 'posts#show', as: 'show_post'
    end
  end

  get '/lifelist/advanced' => 'lifelist#advanced'

  get '/lifelist(/:year)(/:locus)(/:sort)' => 'lifelist#default', as: :lifelist,
      year: /\d{4}/,
      locus: /(?!by_)[^\/]+/, # negative look-ahead: not starting with 'by_'
      sort: /by_taxonomy/

  get 'checklists/:slug' => 'checklists#show', constraints: {slug: 'ukraine'}, as: 'checklist'

  get '/blog.:format' => 'feeds#blog', constraints: {format: 'xml'}
  get '/photos.:format' => 'feeds#photos', constraints: {format: 'xml'}
  get '/sitemap(.:format)' => 'feeds#sitemap', constraints: {format: 'xml'}, defaults: {format: 'xml'}

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
      get 'search(/:with_spots)', defaults: {format: :json}, action: :search, with_spots: /with_spots/
      get 'add'
      get 'bulk'
      post 'bulksave', defaults: {format: :json}
    end
  end

  resources :loci do
    collection do
      get :public
      post :save_order, defaults: {format: :json}
    end
  end

  resources :species, only: [:edit, :update]
  resources :images, except: :show do
    member do
      get 'edit/map', action: :map_edit
      get 'edit/flickr', action: :flickr_edit
      post 'patch'
      get 'observations', defaults: {format: :json}
    end
    collection do
      get 'add'
      get 'flickr_search', defaults: {format: :json}
    end
  end
  resources :comments, except: :new do
    get :reply, on: :member
  end

  resource :map, only: [:show, :edit] do
    resources :spots, only: :index, defaults: {format: :json}
  end

  resources :spots, only: :destroy, defaults: {format: :json} do
    post :save, on: :collection
  end

  resources :authorities do
    resources :book_species, except: [:new, :create, :destroy]
  end

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
