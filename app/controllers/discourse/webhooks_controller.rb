module Discourse
  class WebhooksController < ActionController::API
    def create
      raw_body = request.raw_post

      unless Discourse::VerifyWebhookSignature.call(
        raw_body: raw_body,
        signature: request.headers["X-Discourse-Event-Signature"]
      )
        return head :unauthorized
      end

      event = DiscourseWebhookEvent.find_or_create_by!(
        discourse_event_id: request.headers.fetch("X-Discourse-Event-Id")
      ) do |record|
        record.event_type = request.headers.fetch("X-Discourse-Event-Type")
        record.event_name = request.headers["X-Discourse-Event"]
        record.payload = JSON.parse(raw_body)
      end

      Discourse::DeliverWebhookToSnowflakeJob.perform_later(event.id)

      head :accepted
    rescue JSON::ParserError
      head :bad_request
    end
  end
end
