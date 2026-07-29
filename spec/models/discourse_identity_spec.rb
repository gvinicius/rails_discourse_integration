require 'rails_helper'

RSpec.describe DiscourseIdentity, type: :model do
  it "requires the external identity and username" do
    identity = described_class.new

    expect(identity).not_to be_valid
    expect(identity.errors).to include(:user, :external_id, :discourse_username)
  end
end
