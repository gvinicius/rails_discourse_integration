require "rails_helper"

RSpec.describe Discourse::DeactivateUser do
  let(:client) { instance_double(Discourse::Client) }
  let(:user) do
    User.create!(
      okta_uid: "okta-123",
      email: "alice@example.org",
      name: "Alice Example",
      discourse_username: "alice"
    )
  end

  before do
    user.create_discourse_identity!(
      external_id: user.id.to_s,
      discourse_user_id: 42,
      discourse_username: "alice"
    )

    allow(client).to receive(:revoke_admin)
    allow(client).to receive(:revoke_moderation)
    allow(client).to receive(:deactivate)
  end

  it "revokes privileged access and deactivates the Discourse user" do
    described_class.call(user: user, client: client)

    expect(client).to have_received(:revoke_admin).with(42)
    expect(client).to have_received(:revoke_moderation).with(42)
    expect(client).to have_received(:deactivate).with(42)
    expect(user.discourse_identity.reload.last_sync_status).to eq("deactivated")
  end
end
