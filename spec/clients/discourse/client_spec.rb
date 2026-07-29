require "rails_helper"

RSpec.describe Discourse::Client do
  subject(:client) { described_class.new(base_url: "https://forum.test", api_key: "key", api_username: "system") }

  before do
    ENV["DISCOURSE_BASE_URL"] = "https://forum.test"
    ENV["DISCOURSE_SSO_SECRET"] = "sso-secret"
  end

  after do
    ENV.delete("DISCOURSE_BASE_URL")
    ENV.delete("DISCOURSE_SSO_SECRET")
  end

  it "finds a Discourse user by external id" do
    stub_request(:get, "https://forum.test/users/by-external/community-123")
      .with(headers: { "Api-Key" => "key", "Api-Username" => "system" })
      .to_return(
        status: 200,
        body: { user: { id: 42, username: "alice" } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    expect(client.find_user_by_external_id("community-123")).to include("id" => 42, "username" => "alice")
  end

  it "returns nil when Discourse has no user for the external id" do
    stub_request(:get, "https://forum.test/users/by-external/missing")
      .to_return(status: 404, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    expect(client.find_user_by_external_id("missing")).to be_nil
  end
end
