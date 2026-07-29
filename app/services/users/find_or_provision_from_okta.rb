module Users
  class FindOrProvisionFromOkta
    def self.call(auth:)
      new(auth: auth).call
    end

    def initialize(auth:)
      @auth = auth
    end

    def call
      User.find_or_initialize_by(okta_uid: uid).tap do |user|
        user.email = email
        user.name = name
        user.discourse_username ||= default_discourse_username
        user.active = true
        user.save!
      end
    end

    private

    attr_reader :auth

    def uid
      auth.fetch("uid")
    end

    def email
      auth.dig("info", "email")
    end

    def name
      auth.dig("info", "name").presence || email
    end

    def default_discourse_username
      email.split("@").first.parameterize(separator: "_")
    end
  end
end
