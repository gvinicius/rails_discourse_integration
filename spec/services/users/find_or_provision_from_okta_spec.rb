require "rails_helper"

RSpec.describe Users::FindOrProvisionFromOkta do
  let(:auth) do
    {
      "uid" => "okta-123",
      "info" => {
        "email" => "alice@example.org",
        "name" => "Alice Example"
      }
    }
  end

  it "creates a user from Okta identity data" do
    user = described_class.call(auth: auth)

    expect(user).to be_persisted
    expect(user.okta_uid).to eq("okta-123")
    expect(user.email).to eq("alice@example.org")
    expect(user.name).to eq("Alice Example")
    expect(user.discourse_username).to eq("alice")
  end

  it "updates an existing user" do
    existing =
      User.create!(
        okta_uid: "okta-123",
        email: "old@example.org",
        name: "Old Name",
        discourse_username: "alice"
      )

    user = described_class.call(auth: auth)

    expect(user.id).to eq(existing.id)
    expect(user.email).to eq("alice@example.org")
    expect(user.name).to eq("Alice Example")
  end
end
