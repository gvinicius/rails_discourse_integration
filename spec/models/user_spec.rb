require 'rails_helper'

RSpec.describe User, type: :model do
  it "requires identity fields used by the integration" do
    user = described_class.new

    expect(user).not_to be_valid
    expect(user.errors).to include(:okta_uid, :email, :name, :discourse_username)
  end
end
