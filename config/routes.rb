Quails::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

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
      get 'search'
    end
  end

  get '/photos(/page/:page)' => 'images#index', page: /[^0]\d*/, constraints: {format: 'html'}
  get '/photos/multiple_species' => 'images#multiple_species'
  resources :photos, controller: 'images', as: 'images', except: :index do
    member do
      get 'edit/map', action: :map_edit
      get 'edit/parent', action: :parent_edit
      post 'parent', action: :parent_update
      post 'patch'
      get 'observations'
    end
    collection do
      get 'half_mapped'
      get 'series'
      post 'strip'
      post 'upload'
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
  get '/:id' => 'pages#show_public', constraints: {id: /links|about|winter/}, as: :show_page

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

  resources :cards do
    member do
      post :attach
    end
  end

  resources :observations, except: [:index, :new, :create, :edit] do
    collection do
      get 'search', action: :search, as: 'search'
      get 'extract'
      get 'move'
    end
  end

  scope '/flickr' do
    get 'unflickred' => 'flickr_photos#unflickred', as: 'unflickred_photos'
    get 'unused' => 'flickr_photos#unused', as: 'flickr_unused'
    get 'bou_cc' => 'flickr_photos#bou_cc', as: 'flickr_bou_cc'
    resources :photos, controller: 'flickr_photos', as: 'flickr_photos' do
      post :search, on: :collection
    end
  end

  resources :loci do
    collection do
      get :public
      post :save_order
    end
  end

  resources :patches

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
    get 'photos' => 'spots#photos'
    get 'observations', on: :collection
  end

  resources :spots, only: :destroy do
    post :save, on: :collection
  end

  resources :books do
    resources :taxa, only: [:show, :update]
  end
  get '/books/:id/taxa' => redirect("/books/%{id}")

  resources :pages

  get '/settings' => 'settings#index'
  post '/settings/save' => 'settings#save'

  get '/research(/:action)', controller: :research, as: :research

  get '/login' => 'login#login_page'
  constraints Quails.env.ssl? ? {protocol: 'https://'} : nil do
    post '/login' => 'login#login_do'
  end
  get '/logout' => 'login#logout'

  get '/flickr' => 'flickr#index'
  get '/flickr/auth' => 'flickr#auth'

end
