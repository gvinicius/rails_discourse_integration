class DiscourseGroupMembership < ApplicationRecord
  belongs_to :user

  validates :discourse_group_id, presence: true, uniqueness: { scope: :user_id }
  validates :discourse_group_name, presence: true
end
