class DiscourseWebhookEvent < ApplicationRecord
  validates :discourse_event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :delivery_status, presence: true
end
