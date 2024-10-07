# frozen_string_literal: true

Rails.application.config.to_prepare do
  Scimitar.engine_configuration = Scimitar::EngineConfiguration.new({
    token_authenticator: Proc.new do | token, options |
      true
    end
  })
end