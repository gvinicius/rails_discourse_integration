require 'rails_helper'

RSpec.describe DiscourseGroup, type: :model do
  it "requires a Community role to Discourse group mapping" do
    group = described_class.new

    expect(group).not_to be_valid
    expect(group.errors).to include(:community_role_name, :discourse_group_name, :discourse_group_id)
  end
end
