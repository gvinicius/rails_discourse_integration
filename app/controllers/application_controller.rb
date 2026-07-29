class ApplicationController < ActionController::API
  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: request.headers["X-User-Id"])
  end

  def require_login!
    head :unauthorized unless current_user
  end
end
