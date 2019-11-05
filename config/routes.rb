Rails.application.routes.draw do
  root 'landings#index'

  get '/recently-updated',
      to: 'packages#recent',
      as: :recently_updated

  get '/packages',
      to: 'packages#index',
      as: :packages

  get '/package/:author',
      to: 'packages#by_author',
      as: :repo_author

  get '/package/:author/:repo',
      to: 'versions#show',
      constraints: {
        repo:  %r{[^/]+}
      },
      as: :repo_root

  get '/package/:author/:repo/:version',
      to: 'versions#version',
      constraints: { version: /\d+\.\d+\.\d+/ },
      as: :repo_version

  get '/package/:author/:repo/:version/:category/:entity',
      to: 'versions#entity',
      constraints: {
        version: /\d+\.\d+\.\d+/,
        entity: /.*/
      },
      as: :repo_entity

end
