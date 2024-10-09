# frozen_string_literal: true

module DiscourseScim
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseScim
  end
end