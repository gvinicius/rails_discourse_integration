require "rails_helper"

RSpec.describe Discourse::DeliverWebhookToSnowflakeJob do
  let(:snowflake_client) { instance_double(Snowflake::Client) }
  let(:event) do
    DiscourseWebhookEvent.create!(
      discourse_event_id: "1001",
      event_type: "post",
      event_name: "post_created",
      payload: { "post" => { "id" => 123 } }
    )
  end

  it "transforms and delivers the event" do
    allow(snowflake_client).to receive(:insert_discourse_event)
    allow(Snowflake::Client).to receive(:new).and_return(snowflake_client)

    described_class.perform_now(event.id)

    expect(snowflake_client).to have_received(:insert_discourse_event).with(
      hash_including(
        source: "discourse",
        discourse_event_id: "1001",
        event_name: "post_created"
      )
    )
    expect(event.reload.delivery_status).to eq("delivered")
  end

  it "marks the event failed when Snowflake delivery errors" do
    allow(snowflake_client).to receive(:insert_discourse_event).and_raise(Snowflake::Client::Error, "timeout")
    allow(Snowflake::Client).to receive(:new).and_return(snowflake_client)

    described_class.perform_now(event.id)

    expect(event.reload.delivery_status).to eq("failed")
    expect(event.delivery_error).to eq("timeout")
  end
end
