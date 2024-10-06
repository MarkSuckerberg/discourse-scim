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

module ::DiscourseScimPlugin
  PLUGIN_NAME = "scim"

  require_relative "lib/discourse_scim_plugin/engine"
end