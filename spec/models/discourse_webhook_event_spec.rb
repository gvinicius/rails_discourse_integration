require 'rails_helper'

RSpec.describe DiscourseWebhookEvent, type: :model do
  it "requires idempotency and event routing fields" do
    event = described_class.new

    expect(event).not_to be_valid
    expect(event.errors).to include(:discourse_event_id, :event_type)
  end
end
