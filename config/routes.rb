Rails.application.routes.draw do
  root 'landings#index'

  get '/auth/:provider/callback', to: 'sandbox#login'

  resources :sandbox do
    collection do
      get :recent
      get :user
      get :logout
    end

    member do
      get :preview
      post :fork
      post :format
    end
  end

  get '/guide',
      to: 'guides#index'

  get '/guide/:page',
      to: 'guides#page',
      constraints: {
        page: /.*/
      }

  get '/install',
      to: 'landings#install',
      as: :install

  get '/recently-updated',
      to: 'packages#recent',
      as: :recently_updated

  get '/blog',
      to: 'blog#index',
      as: :blog

  get '/blog/:slug',
      to: 'blog#post',
      as: :blog_post

  get '/package',
      to: 'packages#add',
      as: :add_package

  post '/package',
      to: 'packages#handle_add'

  get '/packages',
      to: 'packages#index',
      as: :packages

  get '/packages/:author',
      to: 'packages#by_author',
      as: :repo_author

  get '/packages/:author/:repo',
      to: 'versions#show',
      constraints: {
        repo:  %r{[^/]+}
      },
      as: :repo_root

  get '/packages/:author/:repo/:version',
      to: 'versions#version',
      constraints: { version: /\d+\.\d+\.\d+/ },
      as: :repo_version

  get '/packages/:author/:repo/:version/:category/:entity',
      to: 'versions#entity',
      constraints: {
        version: /\d+\.\d+\.\d+/,
        entity: /.*/
      },
      as: :_repo_entity

  get '/api',
      to: 'versions#api'

  get '/api/:category/:entity',
      to: 'versions#api_entity',
      constraints: {
        entity: /.*/
      },
      as: :api_entity
end
