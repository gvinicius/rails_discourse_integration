class DiscourseGroup < ApplicationRecord
  validates :community_role_name, presence: true, uniqueness: true
  validates :discourse_group_name, presence: true, uniqueness: true
  validates :discourse_group_id, presence: true, uniqueness: true
end
