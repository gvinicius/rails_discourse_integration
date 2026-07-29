require 'rails_helper'

RSpec.describe CommunityRole, type: :model do
  it "maps known Community roles to Discourse groups" do
    role = described_class.new(name: "moderator")

    expect(role.discourse_group_name).to eq("community-moderators")
  end
end
