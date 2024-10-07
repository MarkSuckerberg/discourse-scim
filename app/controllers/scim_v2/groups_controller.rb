# frozen_string_literal: true

require "scimitar"

module Scim
  class ScimV2::GroupsController < Scimitar::ActiveRecordBackedResourcesController
    # requires_plugin PLUGIN_NAME
    protect_from_forgery with: :null_session

    protected

      def storage_class
          Group
      end

      def storage_scope
          Group.all # Or e.g. "User.where(is_deleted: false)" - whatever base scope you require
      end

  end
end