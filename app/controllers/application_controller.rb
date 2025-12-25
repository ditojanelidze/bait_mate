class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern, if: -> { !turbo_native_app? }

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :turbo_native_app?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def turbo_native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end

  def require_login
    unless logged_in?
      flash[:alert] = I18n.t("auth.login_required")
      redirect_to new_session_path
    end
  end
end
