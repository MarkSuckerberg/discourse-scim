# frozen_string_literal: true

describe "User SCIM endpoints" do
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

  def create_user
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
      displayName: "Test User",
      emails: [
        {
          value: "testuser@example.com",
          type: "work"
        },
      ],
      active: true
    },
    as: :json
  end

  it "can create a user" do
    expect {
      create_user
    }.to change { User.count }.by(1)
    expect(response.status).to eq(201)
  end

  it "can query a user" do
    create_user
    response_content = JSON.parse(response.body)
    get "/scim_v2/Users/#{response_content["id"]}",
    headers: {
      "Authorization" => "Bearer " + scim_api_key.key,
      "Content-Type"  => "application/scim+json"
    },
    as: :json
    expect(response.status).to eq(200)
    response_content = JSON.parse(response.body)
    expect(response_content["displayName"]).to eq("Test User") 
  end
  
  it "can modify a user" do
    create_user
    response_content = JSON.parse(response.body)
    patch "/scim_v2/Users/#{response_content["id"]}",
      headers: {
        "Authorization" => "Bearer " + scim_api_key.key,
        "Content-Type"  => "application/scim+json"
      },
      params: {
        schemas: [
          "urn:ietf:params:scim:schemas:core:2.0:PatchOp"
        ],
        Operations: [
          {
            op: "replace",
            value: {
              displayName: "Changed Name"
            }
          }
        ]
      },
      as: :json
    expect(response.status).to eq(200)

    get "/scim_v2/Users/#{response_content["id"]}",
    headers: {
      "Authorization" => "Bearer " + scim_api_key.key,
      "Content-Type"  => "application/scim+json"
    },
    as: :json
    expect(response.status).to eq(200)
    response_content = JSON.parse(response.body)
    expect(response_content["displayName"]).to eq("Changed Name") 
  end

  it "can delete a user" do
    create_user
    response_content = JSON.parse(response.body)
    delete "/scim_v2/Users/#{response_content["id"]}",
      headers: {
        "Authorization" => "Bearer " + scim_api_key.key,
        "Content-Type"  => "application/scim+json"
      },
      as: :json
    expect(response.status).to eq(204)
  end
end
