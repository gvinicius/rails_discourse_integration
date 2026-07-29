require 'rails_helper'

RSpec.describe DiscourseGroupMembership, type: :model do
  it "requires the locally cached Discourse group membership fields" do
    membership = described_class.new

    expect(membership).not_to be_valid
    expect(membership.errors).to include(:user, :discourse_group_id, :discourse_group_name)
  end
end
