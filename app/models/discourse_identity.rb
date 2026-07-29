class DiscourseIdentity < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :discourse_username, presence: true
  validates :last_sync_status, presence: true
end
