class User < ApplicationRecord
  has_one :discourse_identity, dependent: :destroy
  has_many :community_roles, dependent: :destroy
  has_many :discourse_group_memberships, dependent: :destroy

  validates :okta_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :discourse_username, presence: true, uniqueness: true

  def discourse_identity!
    discourse_identity || raise(ActiveRecord::RecordNotFound, "Discourse identity missing")
  end

  def discourse_admin?
    community_roles.exists?(name: "admin")
  end

  def discourse_moderator?
    community_roles.exists?(name: "moderator")
  end

  def discourse_group_names
    community_roles.filter_map(&:discourse_group_name)
  end
end
