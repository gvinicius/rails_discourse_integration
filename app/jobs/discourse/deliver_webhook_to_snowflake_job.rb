module Discourse
  class DeliverWebhookToSnowflakeJob < ApplicationJob
    queue_as :integrations

    retry_on Snowflake::Client::Error, wait: :polynomially_longer, attempts: 10
    discard_on ActiveRecord::RecordNotFound

    def perform(event_id, snowflake_client: Snowflake::Client.new)
      event = DiscourseWebhookEvent.find(event_id)
      row = Discourse::TransformWebhookForSnowflake.call(event)

      snowflake_client.insert_discourse_event(row)
      event.update!(delivery_status: "delivered", delivery_error: nil)
    rescue Snowflake::Client::Error => e
      event&.update!(delivery_status: "failed", delivery_error: e.message)
      raise
    end
  end
end
