# frozen_string_literal: true

require "scimitar"

module Scim
  class ScimV2::UsersController < Scimitar::ActiveRecordBackedResourcesController
    protect_from_forgery with: :null_session

    # We check for the plugin here manually as we do not inherit from Discourse's ApplicationController
    # and do not have access to requires_plugin
    before_action do
      if plugin = Discourse.plugins_by_name[DiscourseScim::PLUGIN_NAME]
        raise PluginDisabled.new if !plugin.enabled?
      elsif Rails.env.test?
        raise "Required plugin '#{DiscourseScim::PLUGIN_NAME}' not found. The string passed to requires_plugin should match the plugin's name at the top of plugin.rb"
      else
        Rails.logger.warn("Required plugin '#{DiscourseScim::PLUGIN_NAME}' not found")
      end
    end

    protected

      def storage_class
        User
      end

      def storage_scope
        User.where("id >= ?", 0)
      end
  end
end