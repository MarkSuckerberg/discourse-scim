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