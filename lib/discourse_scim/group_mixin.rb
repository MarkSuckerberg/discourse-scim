# frozen_string_literal: true

require "scimitar"

module DiscourseScim::GroupMixin
  module GroupClassMethods
    def scim_resource_type
      Scimitar::Resources::Group
    end
  
    def scim_attributes_map
      {
        id:          :id,
        displayName: :name,
        members:     [
          list:  :scim_users_and_groups,
          using: {
            value: :id
          },
          find_with: -> (scim_list_entry) {
            id   = scim_list_entry['value']
            type = scim_list_entry['type' ] || 'User'
  
            case type.downcase
              when 'user'
                User.find_by_id(id)
              when 'group'
                Group.find_by_id(id)
              else
                User.find_by_id(id)
            end
          }
        ]
      }
    end
  
    def scim_mutable_attributes
      nil
    end
  
    def scim_queryable_attributes
      {
        displayName: :name
      }
    end
  end

  def scim_users_and_groups
    self.users.select{ |item| item.id >= 0 }.to_a + self.associated_groups.to_a
  end

  def scim_users_and_groups=(mixed_array)
    self.users = mixed_array.select { |item| item.is_a?(User) && item.id >=0  }
    self.associated_groups = mixed_array.select { |item| item.is_a?(Group) }
  end

  def self.included(base)
    base.extend GroupClassMethods
  end
end