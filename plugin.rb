# frozen_string_literal: true

# name: discourse-scim-plugin
# about: A plugin to add SCIM endpoints to discourse
# version: 0.0.1
# authors: Peter Bouda
# url: https://github.com/pbouda/discourse-scim-plugin

gem 'marcel', '1.0.0', {require: false }
gem 'activestorage', '7.1.4', {require: false }
gem 'actiontext', '7.1.4', {require: false }
gem 'actionmailbox', '7.1.4', {require: false }
gem 'websocket-extensions', '0.1.0', {require: false }
gem 'websocket-driver', '0.6.1', {require: false }
gem 'actioncable', '7.1.4', {require: false }
gem 'rails', '7.1.4', {require: false }
gem 'scimitar', '2.9.0', {require: false }

require "scimitar"

module ::DiscourseScimPlugin
  PLUGIN_NAME = "scim"

  require_relative "lib/discourse_scim_plugin/engine"
end

after_initialize do
  class ::User
    def self.scim_resource_type
      Scimitar::Resources::User
    end
  
    def self.scim_attributes_map
      {
        id:           :id,
        userName:     :username,
        displayName:  :name,
        name:         {
          formatted:  :name
        },
        emails:       [
          {
            match: "type",
            with:  "work",
            using: {
              value:   :email,
              primary: true
            }
          }
        ],
        active:       :active
      }
    end
    
    def self.scim_timestamps_map
      {
        created:      :created_at,
        lastModified: :updated_at
      }
    end
  
    def self.scim_mutable_attributes
      nil
    end
  
    def self.scim_queryable_attributes
      {
        displayName:      { column: :name },
        userName:         { column: :username },
        emails:           { column: :emails }
      }
    end
  
    include Scimitar::Resources::Mixin
  end
end