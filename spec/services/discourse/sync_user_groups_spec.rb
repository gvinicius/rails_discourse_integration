require "rails_helper"

RSpec.describe Discourse::SyncUserGroups do
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

    DiscourseGroup.create!(
      community_role_name: "moderator",
      discourse_group_name: "community-moderators",
      discourse_group_id: 10
    )

    allow(client).to receive(:add_user_to_group)
    allow(client).to receive(:remove_user_from_group)
    allow(client).to receive(:grant_admin)
    allow(client).to receive(:revoke_admin)
    allow(client).to receive(:grant_moderation)
    allow(client).to receive(:revoke_moderation)
  end

  it "adds missing Discourse groups" do
    user.community_roles.create!(name: "moderator")

    described_class.call(user: user, client: client)

    expect(client).to have_received(:add_user_to_group).with(group_id: 10, username: "alice")
    expect(user.discourse_group_memberships.pluck(:discourse_group_id)).to contain_exactly(10)
  end

  it "removes stale Discourse groups" do
    user.discourse_group_memberships.create!(
      discourse_group_id: 10,
      discourse_group_name: "community-moderators"
    )

    described_class.call(user: user, client: client)

    expect(client).to have_received(:remove_user_from_group).with(group_id: 10, username: "alice")
    expect(user.discourse_group_memberships.reload).to be_empty
  end

  it "syncs moderator and admin flags" do
    user.community_roles.create!(name: "moderator")

    described_class.call(user: user, client: client)

    expect(client).to have_received(:revoke_admin).with(42)
    expect(client).to have_received(:grant_moderation).with(42)
  end

  it "syncs admin role separately from group membership" do
    user.community_roles.create!(name: "admin")

    described_class.call(user: user, client: client)

    expect(client).to have_received(:grant_admin).with(42)
    expect(client).to have_received(:revoke_moderation).with(42)
  end
end
