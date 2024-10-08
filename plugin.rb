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

enabled_site_setting :scim_enabled

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
        groups: [
          {
            list:  :groups,
            using: {
              value:   :id,
              display: :name
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
        emails:           { column: :emails },
        groups:           { column: Group.arel_table[:id] },
        "groups.value" => { column: Group.arel_table[:id] }

      }
    end
  
    include Scimitar::Resources::Mixin
  end

  class ::Group
    def scim_users_and_groups
      self.users.to_a + self.associated_groups.to_a
    end
  
    def scim_users_and_groups=(mixed_array)
      self.users        = mixed_array.select { |item| item.is_a?(User)  }
      self.associated_groups = mixed_array.select { |item| item.is_a?(Group) }
    end

    def self.scim_resource_type
      Scimitar::Resources::Group
    end
  
    def self.scim_attributes_map
      {
        id:          :id,
        displayName: :name,
        members:     [ # NB read-write, though individual items' attributes are immutable
          list:  :scim_users_and_groups, # See adapter accessors, earlier in this file
          using: {
            value: :id
          },
          find_with: -> (scim_list_entry) {
            id   = scim_list_entry['value']
            type = scim_list_entry['type' ] || 'User' # Some online examples omit 'type' and believe 'User' will be assumed
  
            case type.downcase
              when 'user'
                User.find_by_id(id)
              when 'group'
                Group.find_by_id(id)
              else
                raise Scimitar::InvalidSyntaxError.new("Unrecognised type #{type.inspect}")
            end
          }
        ]
      }
    end
  
    def self.scim_mutable_attributes
      nil
    end
  
    def self.scim_queryable_attributes
      {
        displayName: :name
      }
    end
  
    include Scimitar::Resources::Mixin
  end
end