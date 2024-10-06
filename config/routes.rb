# frozen_string_literal: true

require "scimitar"

# DiscourseScimPlugin::Engine.routes.draw do
#   get "/list" => "scim#index"
# end

# Discourse::Application.routes.draw { mount ::DiscourseScimPlugin::Engine, at: "/scim" }

namespace :scim_v2 do
  DiscourseScimPlugin::Engine.routes.draw do
    get    'Users',     to: 'users#index'
    get    'Users/:id', to: 'users#show'
    post   'Users',     to: 'users#create'
    put    'Users/:id', to: 'users#replace'
    patch  'Users/:id', to: 'users#update'
    delete 'Users/:id', to: 'users#destroy'
  end

  Discourse::Application.routes.draw { 
    mount Scimitar::Engine, at: '/scim'
  }
end