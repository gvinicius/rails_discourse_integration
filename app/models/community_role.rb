class CommunityRole < ApplicationRecord
  belongs_to :user

  DISCOURSE_GROUPS = {
    "ifad_staff" => "ifad-staff",
    "country_manager" => "country-managers",
    "moderator" => "community-moderators",
    "admin" => "community-admins"
  }.freeze

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def discourse_group_name
    DISCOURSE_GROUPS[name]
  end
end
