# frozen_string_literal: true

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
  scope "(:locale)", locale: /en|ru/ do
    root to: "blog#home", as: "blog"
  end

  constraints country: /ukraine|usa|united_kingdom|canada|manitoba/ do
    get "/:country/checklist/edit" => "checklist#edit"
    post "/:country/checklist/edit" => "checklist#save"
    scope "(:locale)", locale: /en|ru/ do
      get "/:country" => "countries#gallery", as: "country"
      get "/:country/checklist" => "checklist#show", as: "checklist"
    end
  end

  resources :species, only: [:edit, :update] do
    # index, show - declared localize
    # new, create, destroy - not present
    collection do
      get "admin", action: :index
      get "admin/search", action: :admin_search

      get :review
      get "synonyms" => "synonyms#index"
      patch "synonyms/:id" => "synonyms#update"

      get "splits" => "species_splits#index"
    end
  end

  scope "(:locale)", locale: /en|ru/ do
    resources :species, only: [:show], as: :localized_species do
      get "search", on: :collection
    end
    get "species" => "species#gallery", as: "gallery"
  end

  resources :photos, controller: "images", as: "images", except: [:index, :show] do
    member do
      get "edit/map", action: :map_edit
      post "patch"
    end
    collection do
      post "upload"
    end
  end

  resources :videos, except: [:index, :show] do
    member do
      get "edit/map", action: :map_edit
      post "patch"
    end
  end

  scope "(:locale)", locale: /en|ru/ do
    get "/photos(/page/:page)" => "images#index", page: /[^0]\d*/,
      constraints: { format: "html" }
  end

  scope "(:locale)", locale: /en|ru/ do
    get "/photos/multiple_species" => "images#multiple_species"
    get "photos/:id" => "images#show", as: "localized_image"
    get "/videos(/page/:page)" => "videos#index", page: /[^0]\d*/,
      constraints: { format: "html" }
    get "videos/:id" => "videos#show", as: "localized_video"
    post "media/strip" => "media#strip"
  end

  scope "(:locale)", locale: /en|ru/ do
    constraints year: /20\d\d/ do
      get "/:year" => "blog#year", as: "year"
      constraints month: /(0[1-9])|(1[0-2])/ do
        get "/:year/:month" => "blog#month", as: "month"
        get "/:year/:month/:id" => "posts#show", as: "show_post"
      end
    end
    get "/archive" => "blog#archive"
  end

  direct :public_post do |blogpost, options|
    route_for(:show_post, options.merge(year: blogpost.year, month: blogpost.month, id: blogpost.to_param))
  end

  direct :public_comment do |comment, options|
    # Using `comment.post` breaks Brakeman (post is an http verb)
    comment.public_send(:post).yield_self do |blogpost| # rubocop:disable Style/SendWithLiteralMethodName
      route_for(:show_post, options.merge(year: blogpost.year, month: blogpost.month, id: blogpost.to_param, anchor: "comment#{comment.id}"))
    end
  end

  direct :localize do |obj, options|
    case obj
    when Image
      route_for(:localized_image, options.merge(id: obj.to_param))
    when Video
      route_for(:localized_video, options.merge(id: obj.to_param))
    when Species
      route_for(:localized_species, options.merge(id: obj.to_param))
    else
      obj # May be string
    end
  end

  scope "(:locale)", locale: /en|ru/ do
    get "/lifelist/overview" => "lifelist#index", as: :lists_overview

    get "/lifelist/advanced" => "lifelist#advanced", as: :advanced_list

    get "/lifelist/winter" => "lifelist#winter", as: :winter_list

    get "/lifelist/stats" => "lifelist#stats"

    get "/lifelist/ebird" => "lifelist#ebird"

    get "/lifelist/chart" => "lifelist#chart"

    get "/lifelist" => "lifelist#basic", as: :lifelist

    get "/lifelist(/:locus)(/:year)(/:sort)" => "lifelist#basic", as: :list,
      locus: %r{(?!by_)\D[^/]+}, # negative look-ahead: not starting with 'by_'
      year: /\d{4}/,
      sort: /by_taxonomy/
  end

  # Feeds and sitemap
  get "/blog.:format" => "feeds#blog", constraints: { format: "xml" }
  get "/instant_articles(.:dev).:format" => "feeds#instant_articles", constraints: { format: "xml", dev: "dev" }
  scope "(:locale)", locale: /en|ru/ do
    get "/photos.:format" => "feeds#photos", constraints: { format: "xml" }
  end
  get "/sitemap.:format" => "feeds#sitemap", constraints: { format: "xml" }

  # ADMINISTRATIVE PAGES

  resources :posts, except: [:index, :show] do
    collection do
      get :hidden
      get :facebook
    end
    # member do
    #   get :for_lj
    #   post :lj_post
    # end
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

  resources :observations, except: [:index, :new, :create, :edit] do
    collection do
      get "search", action: :search, as: "search"
      get "extract"
      get "move"
    end
  end

  resources :blobs, only: [:create, :show]

  scope "/flickr" do
    get "unflickred" => "flickr_photos#unflickred", as: "unflickred_photos"
    get "unused" => "flickr_photos#unused", as: "flickr_unused"
    get "bou_cc" => "flickr_photos#bou_cc", as: "flickr_bou_cc"
    resources :photos, controller: "flickr_photos", as: "flickr_photos" do
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

  scope "(:locale)", locale: /en|ru/ do
    resources :comments, only: :create
  end

  resources :comments, except: [:new, :create] do
    get :reply, on: :member
    collection do
      get :unsubscribe, to: "comments#unsubscribe_request", as: :unsubscribe_request
      post :unsubscribe, to: "comments#unsubscribe_submit", as: :unsubscribe_submit
    end
  end

  scope "(:locale)", locale: /en|ru/ do
    resource :map, only: [:show]
  end

  resource :map, only: [:edit] do
    get "media" => "maps#media"
    get "observations", on: :collection
    get "global"
    get "loci"
  end

  resources :spots, only: :destroy do
    post :save, on: :collection
  end

  resources :taxa, except: [:new, :create, :destroy] do
    get :search, on: :collection
  end

  resources :ebird_taxa, only: [:index, :show] do
    member do
      post :promote
    end
  end

  get "/settings" => "settings#index"
  post "/settings/save" => "settings#save"

  scope "/media" do
    get "unmapped" => "media#unmapped"
  end

  get "/reports", controller: :reports, action: :index, as: :reports

  reports_actions = %w(environ insights more_than_year topicture this_day uptoday compare by_countries
    stats voices charts month_targets year_contest server_error)
  reports_actions.each do |name|
    get "/reports/#{name}", controller: :reports, action: name
  end

  get "/reports/five_mile_radius" => "reports/five_mile_radius#index"
  post "/reports/five_mile_radius" => "reports/five_mile_radius#update"

  post "/clear_cache" => "reports#clear_cache"

  resources :corrections do
    get :start, on: :member
  end

  get "/login" => "login#new"
  post "/login" => "login#login"

  get "/logout" => "login#logout"

  get "/flickr" => "flickr#index"
  get "/flickr/auth" => "flickr#auth"

  namespace :ebird do
    get "/" => "portal#index"
    resources :submissions, except: [:edit] do
      post :regenerate, on: :member
    end
    resources :imports, only: [:index, :create] do
      collection do
        post :refresh
      end
    end
  end

  # GoodJob web UI

  constraints ->(request) { request.session[:admin] == true } do
    mount GoodJob::Engine => "/jobs"
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # High Voltage routes are specified manually to bypass HighVoltage Constraints for unrelated paths
  # (e.g. ActiveStorage)

  scope "(:locale)", locale: /en|ru/ do
    get "about" => "pages#show",
      as: :about,
      format: false,
      id: "about"
  end
  scope "(:locale)", locale: /ru/ do
    get "links" => "pages#show",
      as: :links,
      format: false,
      id: "links"
  end
  scope "ru", locale: "ru" do
    get "winter" => "pages#show",
      as: :winter,
      format: false,
      id: "winter"
  end

  namespace :api do
    resources :loci, only: [:index]
    resources :cards, only: [:index]
    resources :observations, only: [:index]
  end

  post "/csp-violation-report-endpoint" => "content_security#report"
end
