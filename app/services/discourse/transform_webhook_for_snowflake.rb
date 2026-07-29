module Discourse
  class TransformWebhookForSnowflake
    def self.call(event)
      new(event).call
    end

    def initialize(event)
      @event = event
    end

    def call
      {
        source: "discourse",
        discourse_event_id: event.discourse_event_id,
        event_type: event.event_type,
        event_name: event.event_name,
        occurred_at: event.created_at.iso8601,
        payload: event.payload,
        loaded_at: Time.current.iso8601
      }
    end

    private

    attr_reader :event
  end
end
