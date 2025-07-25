# frozen_string_literal: true

# name: discourse-scim
# about: A plugin to add SCIM endpoints to discourse
# version: 0.0.1
# authors: Peter Bouda
# url: https://forge.libre.sh/libre.sh/discourse-scim

gem "marcel", "1.0.0", { require: false }
gem "activestorage", "8.0.2", { require: false }
gem "actiontext", "8.0.2", { require: false }
gem "actionmailbox", "8.0.2", { require: false }
gem "websocket-extensions", "0.1.0", { require: false }
gem "websocket-driver", "0.6.1", { require: false }
gem "actioncable", "8.0.2", { require: false }
gem "rails", "8.0.2", { require: false }
gem "scimitar", "2.10.0", { require: false }

require "scimitar"

enabled_site_setting :scim_enabled

add_api_key_scope(
    :scim,
    {
      access_scim_endpoints: {
        actions: %w[scim_v2/users#index scim_v2/users#show scim_v2/users#create
          scim_v2/users#replace scim_v2/users#update scim_v2/users#destroy
          scim_v2/groups#index scim_v2/groups#show scim_v2/groups#create
          scim_v2/groups#update],
      },
    },
  )

module ::DiscourseScim
  PLUGIN_NAME = "discourse-scim"

  require_relative "lib/discourse_scim/engine"
  require_relative "lib/discourse_scim/user_mixin"
  require_relative "lib/discourse_scim/group_mixin"
end

after_initialize do
  class ::User
    include DiscourseScim::UserMixin
    include Scimitar::Resources::Mixin
  end
  
  class ::Group
    include DiscourseScim::GroupMixin
    include Scimitar::Resources::Mixin
  end
end
