module Discourse
  class SsoController < ApplicationController
    before_action :require_login!

    def show
      redirect_to Discourse::SsoRedirectUrl.call(user: current_user, request_query: request.query_string),
                  allow_other_host: true
    end
  end
end
