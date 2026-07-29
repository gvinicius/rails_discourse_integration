require "rails_helper"

RSpec.describe "Discourse webhooks" do
  let(:secret) { "webhook-secret" }
  let(:body) { { post: { id: 123, topic_id: 456 } }.to_json }
  let(:signature) { "sha256=#{OpenSSL::HMAC.hexdigest("sha256", secret, body)}" }

  before do
    ENV["DISCOURSE_WEBHOOK_SECRET"] = secret
  end

  after do
    ENV.delete("DISCOURSE_WEBHOOK_SECRET")
  end

  it "stores a verified webhook event and enqueues Snowflake delivery" do
    expect {
      post "/discourse/webhooks",
           params: body,
           headers: {
             "CONTENT_TYPE" => "application/json",
             "X-Discourse-Event-Id" => "1001",
             "X-Discourse-Event-Type" => "post",
             "X-Discourse-Event" => "post_created",
             "X-Discourse-Event-Signature" => signature
           }
    }.to change(DiscourseWebhookEvent, :count).by(1)
      .and have_enqueued_job(Discourse::DeliverWebhookToSnowflakeJob)

    expect(response).to have_http_status(:accepted)
    expect(DiscourseWebhookEvent.last.event_name).to eq("post_created")
  end

  it "rejects invalid signatures" do
    post "/discourse/webhooks",
         params: body,
         headers: {
           "CONTENT_TYPE" => "application/json",
           "X-Discourse-Event-Id" => "1001",
           "X-Discourse-Event-Type" => "post",
           "X-Discourse-Event-Signature" => "sha256=bad"
         }

    expect(response).to have_http_status(:unauthorized)
  end

  it "is idempotent by Discourse event id" do
    headers = {
      "CONTENT_TYPE" => "application/json",
      "X-Discourse-Event-Id" => "1001",
      "X-Discourse-Event-Type" => "post",
      "X-Discourse-Event-Signature" => signature
    }

    expect {
      2.times { post "/discourse/webhooks", params: body, headers: headers }
    }.to change(DiscourseWebhookEvent, :count).by(1)
  end

  it "rejects malformed JSON" do
    bad_body = "{"
    bad_signature = "sha256=#{OpenSSL::HMAC.hexdigest("sha256", secret, bad_body)}"

    post "/discourse/webhooks",
         params: bad_body,
         headers: {
           "CONTENT_TYPE" => "application/json",
           "X-Discourse-Event-Id" => "1002",
           "X-Discourse-Event-Type" => "post",
           "X-Discourse-Event-Signature" => bad_signature
         }

    expect(response).to have_http_status(:bad_request)
  end
end
