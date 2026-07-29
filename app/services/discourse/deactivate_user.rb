module Discourse
  class DeactivateUser
    def self.call(user:, client: Discourse::Client.new)
      new(user: user, client: client).call
    end

    def initialize(user:, client:)
      @user = user
      @client = client
    end

    def call
      identity = user.discourse_identity
      return unless identity&.discourse_user_id

      client.revoke_admin(identity.discourse_user_id)
      client.revoke_moderation(identity.discourse_user_id)
      client.deactivate(identity.discourse_user_id)

      identity.update!(last_synced_at: Time.current, last_sync_status: "deactivated")
    end

    private

    attr_reader :user, :client
  end
end
