module Discourse
  class SyncUserGroups
    def self.call(user:, client: Discourse::Client.new)
      new(user: user, client: client).call
    end

    def initialize(user:, client:)
      @user = user
      @client = client
    end

    def call
      identity = user.discourse_identity!
      desired_group_ids = desired_discourse_groups.keys
      current_group_ids = current_discourse_groups.keys

      (desired_group_ids - current_group_ids).each do |group_id|
        client.add_user_to_group(group_id: group_id, username: identity.discourse_username)
        create_local_membership(group_id)
      end

      (current_group_ids - desired_group_ids).each do |group_id|
        client.remove_user_from_group(group_id: group_id, username: identity.discourse_username)
        user.discourse_group_memberships.find_by(discourse_group_id: group_id)&.destroy!
      end

      sync_staff_roles(identity)
    end

    private

    attr_reader :user, :client

    def desired_discourse_groups
      @desired_discourse_groups ||=
        user.community_roles.filter_map do |role|
          DiscourseGroup.find_by(community_role_name: role.name)
        end.index_by(&:discourse_group_id)
    end

    def current_discourse_groups
      @current_discourse_groups ||=
        user.discourse_group_memberships.index_by(&:discourse_group_id)
    end

    def create_local_membership(group_id)
      group = desired_discourse_groups.fetch(group_id)
      user.discourse_group_memberships.create!(
        discourse_group_id: group.discourse_group_id,
        discourse_group_name: group.discourse_group_name
      )
    end

    def sync_staff_roles(identity)
      if user.discourse_admin?
        client.grant_admin(identity.discourse_user_id)
      else
        client.revoke_admin(identity.discourse_user_id)
      end

      if user.discourse_moderator?
        client.grant_moderation(identity.discourse_user_id)
      else
        client.revoke_moderation(identity.discourse_user_id)
      end
    end
  end
end
