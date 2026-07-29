module Discourse
  class SsoRedirectUrl
    def self.call(user:, request_query:)
      new(user: user, request_query: request_query).call
    end

    def initialize(user:, request_query:)
      @user = user
      @request_query = request_query
    end

    def call
      incoming = DiscourseApi::SingleSignOn.parse(request_query, sso_secret)
      response = DiscourseApi::SingleSignOn.new

      response.sso_secret = sso_secret
      response.sso_url = discourse_sso_login_url
      response.nonce = incoming.nonce
      response.external_id = user.id.to_s
      response.email = user.email
      response.name = user.name
      response.username = user.discourse_username
      response.admin = user.discourse_admin?
      response.moderator = user.discourse_moderator?
      response.groups = user.discourse_group_names

      response.to_url
    end

    private

    attr_reader :user, :request_query

    def sso_secret
      Rails.application.credentials.dig(:discourse, :sso_secret) || ENV.fetch("DISCOURSE_SSO_SECRET")
    end

    def discourse_sso_login_url
      "#{discourse_base_url}/session/sso_login"
    end

    def discourse_base_url
      Rails.application.credentials.dig(:discourse, :base_url) || ENV.fetch("DISCOURSE_BASE_URL")
    end
  end
end
