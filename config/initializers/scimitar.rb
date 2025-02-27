# frozen_string_literal: true

Rails.application.config.to_prepare do
  Scimitar.service_provider_configuration = Scimitar::ServiceProviderConfiguration.new({
    authenticationSchemes: [
      Scimitar::AuthenticationScheme.bearer
    ]
  })

  Scimitar.engine_configuration = Scimitar::EngineConfiguration.new({
    token_authenticator: Proc.new do | token, options |
      api_key = ApiKey.active.with_key(token).first
      allowed = false
      if api_key
        allowed = api_key.api_key_scopes.empty? || api_key.api_key_scopes.any? { |s| s.resource == "scim" || s.action == "access_scim_endpoints" }
      end
      allowed
    end
  })
end