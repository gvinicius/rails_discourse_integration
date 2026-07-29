require "rails_helper"

RSpec.describe Discourse::VerifyWebhookSignature do
  let(:secret) { "webhook-secret" }
  let(:raw_body) { { post: { id: 123 } }.to_json }

  before do
    ENV["DISCOURSE_WEBHOOK_SECRET"] = secret
  end

  after do
    ENV.delete("DISCOURSE_WEBHOOK_SECRET")
  end

  it "accepts a valid signature" do
    digest = OpenSSL::HMAC.hexdigest("sha256", secret, raw_body)

    expect(described_class.call(raw_body: raw_body, signature: "sha256=#{digest}")).to be(true)
  end

  it "rejects an invalid signature" do
    expect(described_class.call(raw_body: raw_body, signature: "sha256=bad")).to be(false)
  end

  it "rejects missing signatures" do
    expect(described_class.call(raw_body: raw_body, signature: nil)).to be(false)
  end
end
