module Discourse
  class SyncUserJob < ApplicationJob
    queue_as :integrations

    retry_on Discourse::Client::RateLimited, wait: :polynomially_longer, attempts: 8
    retry_on Discourse::Client::Error, wait: 5.minutes, attempts: 5
    discard_on ActiveRecord::RecordNotFound

    def perform(user_id)
      Discourse::SyncUser.call(user: User.find(user_id))
    end
  end
end
