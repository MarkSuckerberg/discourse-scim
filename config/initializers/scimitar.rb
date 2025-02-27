# frozen_string_literal: true

class EditableUserGroups < Scimitar::Schema::Base
  def initialize(options = {})
    super(
      name:            'EditableUserGroups',
      description:     'A field to allow for the editing of user groups on the user endpoint.',
      id:              self.class.id,
      scim_attributes: self.class.scim_attributes
    )
  end

  def self.id
    'urn:ietf:params:scim:shiptest:schemas:UserGroups'
  end

  def self.scim_attributes
    [
      Scimitar::Schema::Attribute.new(name: "userGroups", multiValued: true, complexType: Scimitar::ComplexTypes::ReferenceGroup, mutability: "writeOnly"),
    ]
  end
end

Rails.application.config.to_prepare do
  Scimitar.service_provider_configuration = Scimitar::ServiceProviderConfiguration.new({
    authenticationSchemes: [
      Scimitar::AuthenticationScheme.bearer
    ]
  })

  Scimitar::Resources::User.extend_schema(EditableUserGroups)
  
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