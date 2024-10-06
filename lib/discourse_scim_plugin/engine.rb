# frozen_string_literal: true

module DiscourseScimPlugin
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseScimPlugin
  end
end