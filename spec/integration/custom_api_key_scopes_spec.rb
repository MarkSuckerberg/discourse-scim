# frozen_string_literal: true

describe "API keys scoped to scim#access_scim_endpoints" do
  before do
    SiteSetting.chat_enabled = true
    SiteSetting.chat_allowed_groups = Group::AUTO_GROUPS[:everyone]
  end
  
  fab!(:admin)

  let(:scim_api_key) do
    key = ApiKey.create!
    ApiKeyScope.create!(resource: "scim", action: "access_scim_endpoints", api_key_id: key.id)
    key
  end

  it "cannot hit any other endpoints" do
    get "/admin/users/list/active.json",
        headers: {
          "Api-Key" => scim_api_key.key,
          "Api-Username" => admin.username,
        }
    expect(response.status).to eq(404)

    get "/latest.json", headers: { "Api-Key" => scim_api_key.key, "Api-Username" => admin.username }
    expect(response.status).to eq(403)
  end

  it "can create a user" do
    expect {
      post "/scim_v2/Users",
        headers: {
          "Authorization" => "Bearer " + scim_api_key.key,
          "Content-Type"  => "application/scim+json"
        },
        params: {
          schemas: [
            "urn:ietf:params:scim:schemas:core:2.0:User"
          ],
          userName: "testUser",
          name: {
            familyName: "Test",
            givenName: "User"
          },
          emails: [
            {
              value: "testuser@example.com",
              type: "work"
            },
          ],
          active: true
        },
        as: :json
    }.to change { User.count }.by(1)
    expect(response.status).to eq(201)
  end
end
