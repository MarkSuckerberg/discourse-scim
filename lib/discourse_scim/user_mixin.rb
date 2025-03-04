# frozen_string_literal: true

require "scimitar"

module DiscourseScim::UserMixin
  def scim_email_mapper=(scim_emails)
    user_emails = scim_emails.map do |scim_email|
      UserEmail.build({
        email: scim_emails[0][:value],
        primary: scim_emails[0].key?(:type) || scim_emails[0][:type] == "work"
      })
    end

    primary_email = user_emails[0]
    primary_emails = user_emails.select { |value| value.primary }
    if primary_emails.length() > 0
      primary_email = primary_emails[0]
    end

    self.user_emails = user_emails
    self.primary_email = primary_email
  end

  def scim_email_mapper
    self.user_emails.map do |user_email|
      scim_email = { value: user_email[:email] }
      if user_email[:primary]
        scim_email[:type] = "primary"
      end
      scim_email
    end
  end

  def scim_roles_mapper=(scim_roles)
    deadmin = self.admin
    demod = self.moderator

    self.groups = scim_roles.map do |scim_role|
      case Integer(scim_role[:value])
        when 1
          deadmin = false
          self.grant_admin!
        when 2
          demod = false
          self.grant_moderation!
        when 10..14
          self.change_trust_level!(Integer(scim_role[:value]) - 10)
      end
      Group.find(scim_role[:value])
    end

    if deadmin
      self.revoke_admin!
    end

    if demod
      self.revoke_moderation!
    end

    self.set_automatic_groups
  end

  def scim_roles_mapper
    self.groups.map do |user_group|
      { value: user_group[:id], display: user_group[:name] }
    end
  end

  module UserClassMethods
    def scim_resource_type
      Scimitar::Resources::User
    end

    def scim_attributes_map
      {
        id:          :id,
        userName:    :username,
        displayName: :name,
        emails:      :scim_email_mapper,
        groups:      :scim_roles_mapper,
        roles:       :scim_roles_mapper,
        active: :active
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