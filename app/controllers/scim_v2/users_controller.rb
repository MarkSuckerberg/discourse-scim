# frozen_string_literal: true

require "scimitar"

module Scim
  class ScimV2::UsersController < Scimitar::ActiveRecordBackedResourcesController
    # requires_plugin PLUGIN_NAME
    protect_from_forgery with: :null_session

    protected

      def storage_class
        User
      end

      def storage_scope
        User.all # Or e.g. "User.where(is_deleted: false)" - whatever base scope you require
      end

  end
end