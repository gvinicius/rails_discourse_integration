require "rails_helper"

RSpec.describe Discourse::SsoRedirectUrl do
  let(:secret) { "super-secret-discourse-connect-key" }
  let(:user) do
    User.create!(
      okta_uid: "okta-123",
      email: "alice@example.org",
      name: "Alice Example",
      discourse_username: "alice"
    )
  end

  before do
    ENV["DISCOURSE_SSO_SECRET"] = secret
    ENV["DISCOURSE_BASE_URL"] = "https://forum.test"
    user.community_roles.create!(name: "moderator")
  end

  after do
    ENV.delete("DISCOURSE_SSO_SECRET")
    ENV.delete("DISCOURSE_BASE_URL")
  end

  it "returns a signed Discourse login URL preserving the nonce" do
    incoming = DiscourseApi::SingleSignOn.new
    incoming.sso_secret = secret
    incoming.nonce = "nonce-123"

    url = described_class.call(user: user, request_query: incoming.payload)
    uri = URI.parse(url)
    parsed = DiscourseApi::SingleSignOn.parse(uri.query, secret)

    expect(uri.to_s).to start_with("https://forum.test/session/sso_login")
    expect(parsed.nonce).to eq("nonce-123")
    expect(parsed.external_id).to eq(user.id.to_s)
    expect(parsed.email).to eq("alice@example.org")
    expect(parsed.username).to eq("alice")
    expect(parsed.moderator).to be(true)
    expect(parsed.groups).to eq([ "community-moderators" ])
  end
end
