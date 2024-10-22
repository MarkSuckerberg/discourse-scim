# frozen_string_literal: true

require "scimitar"

module DiscourseScim::UserMixin
  module UserClassMethods
    def scim_resource_type
      Scimitar::Resources::User
    end

    def scim_attributes_map
      {
        id:           :id,
        userName:     :username,
        displayName:  :name,
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
    
    def scim_timestamps_map
      {
        created:      :created_at,
        lastModified: :updated_at
      }
    end

    def scim_mutable_attributes
      nil
    end

    def scim_queryable_attributes
      {
        displayName:      { column: :name },
        userName:         { column: :username },
        emails:           { column: :emails },
        groups:           { column: Group.arel_table[:id] },
        "groups.value" => { column: Group.arel_table[:id] }

      }
    end
  end

  def self.included(base)
    base.extend UserClassMethods
  end
end