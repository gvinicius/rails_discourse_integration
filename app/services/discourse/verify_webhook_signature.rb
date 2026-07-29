module Discourse
  class VerifyWebhookSignature
    def self.call(raw_body:, signature:)
      new(raw_body: raw_body, signature: signature).call
    end

    def initialize(raw_body:, signature:)
      @raw_body = raw_body
      @signature = signature.to_s
    end

    def call
      return false unless signature.start_with?("sha256=")
      return false unless signature.bytesize == expected_signature.bytesize

      ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
    end

    private

    attr_reader :raw_body, :signature

    def expected_signature
      digest = OpenSSL::HMAC.hexdigest("sha256", secret, raw_body)
      "sha256=#{digest}"
    end

    def secret
      Rails.application.credentials.dig(:discourse, :webhook_secret) || ENV.fetch("DISCOURSE_WEBHOOK_SECRET")
    end
  end
end
