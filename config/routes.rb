# frozen_string_literal: true

require "scimitar"

Discourse::Application.routes.draw { 
  namespace :scim_v2 do
    mount Scimitar::Engine, at: '/'
      
    get    'Users',     to: 'users#index'
    get    'Users/:id', to: 'users#show'
    post   'Users',     to: 'users#create'
    put    'Users/:id', to: 'users#replace'
    patch  'Users/:id', to: 'users#update'
    delete 'Users/:id', to: 'users#destroy'
      
    get    'Groups',     to: 'groups#index'
    get    'Groups/:id', to: 'groups#show'
    post   'Groups',     to: 'groups#create'
    patch  'Groups/:id', to: 'groups#update'
  end
}
