Rails.application.routes.draw do

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


  # PUBLIC PAGES

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'blog#home', as: 'blog'

  constraints country: /ukraine|usa|united_kingdom|canada|manitoba/ do
    get '/:country/checklist/edit' => 'checklist#edit'
    post '/:country/checklist/edit' => 'checklist#save'
    scope '(:locale)', locale: /en/ do
      get '/:country' => 'countries#gallery', as: "country"
      get '/:country/checklist' => 'checklist#show', as: "checklist"
    end
  end

  resources :legacy_species, only: [:index, :show]

  resources :species, only: [:edit, :update] do
    # index, show - declared localize
    # new, create, destroy - not present
    collection do
      get 'admin', action: :index

      get "synonyms" => "synonyms#index"
      patch "synonyms/:id" => "synonyms#update"

      get "splits" => "species_splits#index"
    end
  end

  scope '(:locale)', locale: /en/ do
    resources :species, only: [:show], as: :localized_species do
      get 'search', on: :collection
    end
    get 'species' => 'species#gallery', as: 'gallery'
  end

  resources :photos, controller: 'images', as: 'images', except: [:index, :show] do
    member do
      get 'edit/map', action: :map_edit
      post 'patch'
      get 'observations'
    end
    collection do
      get 'series'
      post 'upload'
    end
  end

  resources :videos, except: [:index, :show] do
    member do
      get 'edit/map', action: :map_edit
      post 'patch'
    end
    collection do
    end
  end

  get '/photos(/page/:page)' => 'images#index', page: /[^0]\d*/,
      constraints: {format: 'html'}

  scope '(:locale)', locale: /en/ do
    get '/photos/multiple_species' => 'images#multiple_species'
    get 'photos/:id' => 'images#show', as: 'localized_image'
    get '/videos(/page/:page)' => 'videos#index', page: /[^0]\d*/,
        constraints: {format: 'html'}
    get 'videos/:id' => 'videos#show', as: 'localized_video'
    post 'media/strip' => 'media#strip'
  end

  constraints year: /20\d\d/ do
    get '/:year' => 'blog#year', as: 'year'
    constraints month: /(0[1-9])|(1[0-2])/ do
      get '/:year/:month' => 'blog#month', as: 'month'
      get '/:year/:month/:id' => 'posts#show', as: 'show_post'
    end
  end

  get '/archive' => 'blog#archive'

  scope '(:locale)', locale: /en/ do

    get '/lists' => 'lists#index'

    get '/lists/advanced' => 'lists#advanced', as: :advanced_list

    get '/lists/stats' => 'lists#stats'

    get '/lists/life(/:sort)' => 'lists#basic', as: :lifelist

    get '/lists(/:locus)(/:year)(/:sort)' => 'lists#basic', as: :list,
        locus: /(?!by_)\D[^\/]+/, # negative look-ahead: not starting with 'by_'
        year: /\d{4}/,
        sort: /by_taxonomy/
  end

  # Feeds and sitemap
  get '/blog.:format' => 'feeds#blog', constraints: {format: 'xml'}
  get '/instant_articles(.:dev).:format' => 'feeds#instant_articles', constraints: {format: 'xml', dev: "dev"}
  scope '(:locale)', locale: /en/ do
    get '/photos.:format' => 'feeds#photos', constraints: {format: 'xml'}
  end
  get '/sitemap.:format' => 'feeds#sitemap', constraints: {format: 'xml'}

  # TRANSLATED:

  scope ':locale', locale: /en/ do
    get '(/page/:page)' => 'images#index', page: /[^0]\d*/, as: :localized_root
    get 'photos' => redirect("/%{locale}")
  end

  # ADMINISTRATIVE PAGES

  resources :posts, except: [:index, :show] do
    collection do
      get :hidden
      get :facebook
    end
    post :lj_post, on: :member
  end

  resources :cards do
    member do
      post :attach
    end
    collection do
      get :import
    end
  end

  resources :days, only: [:index, :show]

  scope '/observations' do
    resources :spuhs, only: [:index, :show, :update]
  end

  resources :observations, except: [:index, :new, :create, :edit] do
    collection do
      get 'search', action: :search, as: 'search'
      get 'extract'
      get 'move'
    end
  end

  resources :blobs, only: [:create, :show]

  scope '/flickr' do
    get 'unflickred' => 'flickr_photos#unflickred', as: 'unflickred_photos'
    get 'unused' => 'flickr_photos#unused', as: 'flickr_unused'
    get 'bou_cc' => 'flickr_photos#bou_cc', as: 'flickr_bou_cc'
    resources :photos, controller: 'flickr_photos', as: 'flickr_photos' do
      post :search, on: :collection
      post :push_to_storage, on: :member
    end
  end

  resources :loci do
    collection do
      get :public
      post :save_order
    end
  end

  resources :comments, except: :new do
    get :reply, on: :member
    collection do
      get :unsubscribe, to: "comments#unsubscribe_request", as: :unsubscribe_request
          post :unsubscribe, to: "comments#unsubscribe_submit", as: :unsubscribe_submit
    end
  end

  scope '(:locale)', locale: /en/ do
    resource :map, only: [:show]
  end

  resource :map, only: [:edit] do
    get 'media' => 'maps#media'
    get 'observations', on: :collection
    get 'global'
    get 'loci'
  end

  resources :spots, only: :destroy do
    post :save, on: :collection
  end

  resources :books do
    resources :legacy_taxa, only: [:show, :update]
  end

  resources :taxa, except: [:new, :create, :destroy] do
    get :search, on: :collection
  end

  resources :ebird_taxa, only: [:index, :show] do
    member do
      post :promote
    end
  end

  get '/settings' => 'settings#index'
  post '/settings/save' => 'settings#save'

  scope "/media" do
    get "unmapped" => "media#unmapped"
    resources :series, controller: "media_series"
  end

  get '/research', controller: :research, action: :index, as: :research

  research_actions = %w(environ insights more_than_year topicture this_day uptoday compare by_countries stats voices charts month_targets)
  research_actions.each do |name|
    get "/research/#{name}", controller: :research, action: name
  end

  get '/login' => 'login#login_page'
  post '/login' => 'login#login_do'

  get '/logout' => 'login#logout'

  get '/flickr' => 'flickr#index'
  get '/flickr/auth' => 'flickr#auth'

  namespace :ebird do
    get '/' => "portal#index"
    resources :submissions, except: [:edit] do
      post :regenerate, on: :member
    end
    resources :imports
  end

  # Resque web front

  require 'resque/server'

  resque_web_constraint = lambda do |request|
    current_user ||= User.from_session(request)
    current_user.admin?
  end

  constraints resque_web_constraint do
    mount Resque::Server.new => "/resque"
  end

end
