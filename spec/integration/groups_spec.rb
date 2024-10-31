# frozen_string_literal: true

describe "Group SCIM endpoints" do
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

  def create_group
    post "/scim_v2/Groups",
    headers: {
      "Authorization" => "Bearer " + scim_api_key.key,
      "Content-Type"  => "application/scim+json"
    },
    params: {
      schemas: [
        "urn:ietf:params:scim:schemas:core:2.0:Group"
      ],
      displayName: "TestGroup",
      members: [
        { "value": "1" }
      ]
    },
    as: :json
  end

  it "can create a group" do
    expect {
      create_group
    }.to change { Group.count }.by(1)
    expect(response.status).to eq(201)
  end

  it "can query a group" do
    create_group
    response_content = JSON.parse(response.body)
    get "/scim_v2/Groups/#{response_content["id"]}",
    headers: {
      "Authorization" => "Bearer " + scim_api_key.key,
      "Content-Type"  => "application/scim+json"
    },
    as: :json
    expect(response.status).to eq(200)
    response_content = JSON.parse(response.body)
    expect(response_content["displayName"]).to eq("TestGroup") 
  end

  it "can modify a group" do
    create_group
    response_content = JSON.parse(response.body)
    patch "/scim_v2/Groups/#{response_content["id"]}",
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
              displayName: "ChangedName"
            }
          }
        ]
      },
      as: :json
    expect(response.status).to eq(200)

    get "/scim_v2/Groups/#{response_content["id"]}",
    headers: {
      "Authorization" => "Bearer " + scim_api_key.key,
      "Content-Type"  => "application/scim+json"
    },
    as: :json
    expect(response.status).to eq(200)
    response_content = JSON.parse(response.body)
    expect(response_content["displayName"]).to eq("ChangedName") 
  end

  it "can delete a group" do
    create_group
    response_content = JSON.parse(response.body)
    delete "/scim_v2/Groups/#{response_content["id"]}",
      headers: {
        "Authorization" => "Bearer " + scim_api_key.key,
        "Content-Type"  => "application/scim+json"
      },
      as: :json
    expect(response.status).to eq(204)
  end
end
