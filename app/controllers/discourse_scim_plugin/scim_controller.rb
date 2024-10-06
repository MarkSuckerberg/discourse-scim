# frozen_string_literal: true

module ::DiscourseScimPlugin
  class ScimController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json: { hello: "world" }
    end
  end
end