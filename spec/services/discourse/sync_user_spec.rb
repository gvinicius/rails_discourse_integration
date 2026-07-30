require "rails_helper"

RSpec.describe Discourse::SyncUser do
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
    user.community_roles.create!(name: "moderator")
  end

  it "syncs a user through DiscourseConnect sync_sso" do
    expect(client).to receive(:sync_sso_user).with(
      hash_including(
        external_id: user.id.to_s,
        email: "alice@example.org",
        username: "alice",
        moderator: true,
        groups: [ "community-moderators" ]
      )
    )

    allow(client).to receive(:find_user_by_external_id)
      .with(user.id.to_s)
      .and_return({ "id" => 42, "username" => "alice" })

    identity = described_class.call(user: user, client: client)

    expect(identity.discourse_user_id).to eq(42)
    expect(identity.last_sync_status).to eq("ok")
    expect(identity.last_sync_error).to be_nil
  end

  it "records failed sync attempts" do
    allow(client).to receive(:sync_sso_user).and_raise(Discourse::Client::Error, "boom")

    expect {
      described_class.call(user: user, client: client)
    }.to raise_error(Discourse::Client::Error)

    expect(user.reload.discourse_identity.last_sync_status).to eq("failed")
    expect(user.discourse_identity.last_sync_error).to eq("boom")
  end
end
