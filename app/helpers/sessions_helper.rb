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

  def sign_in(user:, impersonate: false, fingerprint_info: {})
    # Generate a secure random token
    session_token = SecureRandom.urlsafe_base64(64)

    # Get the impersonator if this is an impersonation
    impersonated_by = impersonate ? current_user : nil

    # Set expiration time based on user preferences
    expiration_at = Time.current + user.session_duration_seconds.seconds

    # Create the session in the database
    db_session = User::Session.create!(
      user: user,
      impersonated_by: impersonated_by,
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

    # Critical: Set the user ID in the session
    session[:user_id] = user.id

    # Debug info
    Rails.logger.info "Session created for user: #{user.id}, token: #{session_token[0..5]}..."

    # Return the session
    db_session
  end

  def current_user
    # Primary method: use the session user_id
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
      return @current_user if @current_user
    end

    # Fallback: try to find user via session token
    if cookies.encrypted[:session_token]
      user_session = current_session
      if user_session && !user_session.expired?
        @current_user = user_session.user
        # Sync the session
        session[:user_id] = @current_user.id
        return @current_user
      end
    end

    nil
  end

  def current_session
    return @current_session if defined?(@current_session)

    session_token = cookies.encrypted[:session_token]
    return nil if session_token.nil?

    # Use the find_current_session method from User::Session
    @current_session = User::Session.find_current_session(session_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    # Find and invalidate the current session in the database
    if cookies.encrypted[:session_token].present?
      user_session = User::Session.find_by(token: cookies.encrypted[:session_token])
      user_session&.update(signed_out_at: Time.current, expiration_at: Time.current)
    end

    # Remove the session token cookie
    cookies.delete(:session_token)

    # Clear the session
    session.delete(:user_id)
    @current_user = nil
    @current_session = nil
  end

  def sign_out_of_all_sessions(user = current_user)
    # Just sign out all sessions for the user
    user&.user_sessions&.update_all(
      signed_out_at: Time.current,
      expiration_at: Time.current
    )
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
