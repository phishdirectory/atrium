# frozen_string_literal: true

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :session_timeout, if: -> { current_session }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Track papertrail edits to specific users
  # before_action :set_paper_trail_whodunnit (we don't need this anymore)

  # before_action do
  #   # Disallow indexing
  # response.set_header("X-Robots-Tag", "noindex")
  # end

  # # Enable Rack::MiniProfiler for admins
  before_action do
    if admin_signed_in?
      Rack::MiniProfiler.authorize_request
    end
  end

  helper_method :current_user_data, :current_session, :signed_in?, :admin_signed_in?

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    if signed_in? || !request.get?
      redirect_to root_path
    else
      redirect_to login_path(return_to: request.url)
    end
  end

  def not_found
    raise ActionController::RoutingError, "Not Found"
  end

  def confetti!(emojis: nil)
    flash[:confetti] = true
    flash[:confetti_emojis] = emojis.join(",") if emojis
  end

  def authenticate_user
    redirect_to login_path unless current_session
  end

end
