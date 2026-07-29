module Discourse
  class SyncUser
    def self.call(user:, client: Discourse::Client.new)
      new(user: user, client: client).call
    end

    def initialize(user:, client:)
      @user = user
      @client = client
    end

    def call
      identity = user.discourse_identity || user.build_discourse_identity(
        external_id: user.id.to_s,
        discourse_username: user.discourse_username
      )

      client.sync_sso_user(
        external_id: user.id.to_s,
        email: user.email,
        name: user.name,
        username: user.discourse_username,
        admin: user.discourse_admin?,
        moderator: user.discourse_moderator?,
        groups: user.discourse_group_names,
        require_activation: !user.active?
      )

      discourse_user = client.find_user_by_external_id(user.id.to_s)

      identity.update!(
        discourse_user_id: discourse_user&.fetch("id", nil),
        discourse_username: user.discourse_username,
        last_synced_at: Time.current,
        last_sync_status: "ok",
        last_sync_error: nil
      )

      identity
    rescue Discourse::Client::RateLimited, Discourse::Client::Error => e
      mark_failed(identity, e)
      raise
    end

    private

    attr_reader :user, :client

    def mark_failed(identity, error)
      identity&.save! if identity&.new_record?
      identity&.update!(last_sync_status: "failed", last_sync_error: error.message)
    end
  end
end
