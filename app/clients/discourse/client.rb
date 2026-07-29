module Discourse
  class Client
    class Error < StandardError; end
    class NotFound < Error; end
    class RateLimited < Error; end
    class InvalidRecord < Error; end

    def initialize(base_url: discourse_credential(:base_url),
                   api_key: discourse_credential(:api_key),
                   api_username: discourse_credential(:api_username))
      @client = DiscourseApi::Client.new(base_url)
      @client.api_key = api_key
      @client.api_username = api_username
    end

    def find_user_by_external_id(external_id)
      @client.by_external_id(external_id)
    rescue DiscourseApi::NotFoundError
      nil
    rescue DiscourseApi::TooManyRequests => e
      raise RateLimited, e.message
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def sync_sso_user(payload)
      @client.sync_sso(payload.merge(sso_secret: sso_secret, sso_url: discourse_sso_login_url))
    rescue DiscourseApi::UnprocessableEntity => e
      raise InvalidRecord, extract_error(e)
    rescue DiscourseApi::TooManyRequests => e
      raise RateLimited, e.message
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def add_user_to_group(group_id:, username:)
      @client.group_add(group_id, usernames: [username])
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def remove_user_from_group(group_id:, username:)
      @client.group_remove(group_id, usernames: [username])
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def grant_admin(user_id)
      @client.grant_admin(user_id)
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def revoke_admin(user_id)
      @client.revoke_admin(user_id)
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def grant_moderation(user_id)
      @client.grant_moderation(user_id)
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def revoke_moderation(user_id)
      @client.revoke_moderation(user_id)
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    def deactivate(user_id)
      @client.deactivate(user_id)
    rescue DiscourseApi::Error => e
      raise Error, e.message
    end

    private

    def sso_secret
      discourse_credential(:sso_secret)
    end

    def discourse_sso_login_url
      "#{discourse_credential(:base_url)}/session/sso_login"
    end

    def discourse_credential(key)
      Rails.application.credentials.dig(:discourse, key) || ENV.fetch("DISCOURSE_#{key.to_s.upcase}")
    end

    def extract_error(error)
      body = error.response&.body
      return error.message unless body.respond_to?(:[])

      Array(body["errors"]).join(", ").presence || error.message
    end
  end
end
