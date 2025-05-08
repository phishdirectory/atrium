# frozen_string_literal: true

# app/helpers/sessions_helper.rb
module SessionsHelper
  SESSION_DURATION_OPTIONS = {
    "1 hour"  => 1.hour.to_i,
    "1 day"   => 1.day.to_i,
    "3 days"  => 3.days.to_i,
    "7 days"  => 7.days.to_i,
    "14 days" => 14.days.to_i,
    "30 days" => 30.days.to_i
  }.freeze

  # Modified to work with external auth
  def sign_in(user_data:, fingerprint_info: {})
    # Generate a secure random token
    session_token = SecureRandom.urlsafe_base64(64)

    # Store the pd_id in the session
    session[:pd_id] = user_data["pd_id"]

    # Sync with profile
    profile = Profile.sync_from_api(user_data)


    # Set default session duration (30 days)
    session_duration = 30.days.to_i

    # Set expiration time
    expiration_at = Time.current + session_duration

    # Create the session in the database
    user_session = UserSession.create!(
      pd_id: user_data["pd_id"],
      user_data: user_data,
      session_token: session_token,
      expiration_at: expiration_at,
      fingerprint: fingerprint_info[:fingerprint],
      device_info: fingerprint_info[:device_info],
      os_info: fingerprint_info[:os_info],
      timezone: fingerprint_info[:timezone],
      ip: fingerprint_info[:ip]
    )

    # Set an encrypted cookie with the session token
    cookies.encrypted[:session_token] = {
      value: session_token,
      expires: expiration_at,
      httponly: true,
      secure: Rails.env.production?
    }

    # Return the session
    user_session
  end

  def require_login
    return if current_session

    store_location
    flash[:alert] = "Please log in to access this page."
    redirect_to login_path
  end

  def store_location
    session[:return_to] = request.original_url if request.get?
  end

  def session_timeout
    return unless current_session

    idle_time = 30.minutes

    if current_session.last_seen_at && current_session.last_seen_at < idle_time.ago
      sign_out
      flash[:alert] = "Your session has expired due to inactivity. Please sign in again."
      redirect_to login_path
    else
      current_session.touch_last_seen_at
    end
  end

  def signed_in?
    !current_session.nil?
  end

  def admin_signed_in?
    signed_in? && (current_user_data["permissions"]["global_access_level"]["value"] >= 1)
  end

  def current_user_data
    @current_user_data ||= current_session&.user_data
  end

  def current_session
    return @current_session if defined?(@current_session)

    session_token = cookies.encrypted[:session_token]
    return nil if session_token.nil?

    # Find a valid session (not expired) using the session token
    @current_session = UserSession.not_expired.find_by(session_token: session_token)
  end

  def current_profile
    @current_profile ||= Profile.find_by(pd_id: current_session&.pd_id)
  end

  def current_user_sessions
    UserSession.where(pd_id: current_session&.pd_id).order(created_at: :desc)
  end

  def sign_out
    current_session&.update(signed_out_at: Time.zone.now, expiration_at: Time.zone.now)
    cookies.delete(:session_token)
    session.delete(:pd_id)
    @current_session = nil
    @current_user_data = nil
  end

  def sign_out_of_all_sessions
    # Destroy all the sessions except the current session
    UserSession.where(pd_id: current_session.pd_id)
               .where.not(id: current_session.id)
               .update_all(signed_out_at: Time.zone.now, expiration_at: Time.zone.now)
  end

end
