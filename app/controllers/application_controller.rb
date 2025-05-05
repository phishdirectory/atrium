# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper

  # Only add the session_timeout before action if the method exists in SessionsHelper
  before_action :check_session_timeout, if: -> { current_user && respond_to?(:session_timeout, true) }

  # Track papertrail edits to specific users
  before_action :set_paper_trail_whodunnit, if: -> { respond_to?(:set_paper_trail_whodunnit, true) }

  # Enable Rack::MiniProfiler for admins
  before_action do
    if defined?(Rack::MiniProfiler) && current_user&.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  helper_method :current_user

  def check_session_timeout
    session_timeout if respond_to?(:session_timeout, true)
  end

  def set_paper_trail_whodunnit
    PaperTrail.request.whodunnit = current_user&.id.to_s if defined?(PaperTrail)
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    if current_user || !request.get?
      redirect_to root_path
    else
      redirect_to login_path(return_to: request.url)
    end
  end

  def not_found
    raise ActionController::RoutingError, "Not Found"
  end

  def authenticate_user
    return if current_user

    store_location
    flash[:alert] = "Please log in to access this page."
    redirect_to login_path

  end

  def store_location
    session[:return_to] = request.original_url if request.get?
  end

end
