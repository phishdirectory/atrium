# frozen_string_literal: true

# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
    # Login form
    redirect_to root_path if current_session
  end

  def create
    # Authenticate using the external API service
    user_data = AuthService.authenticate(params[:email], params[:password])

    if user_data
      # Create a session for the authenticated user
      fingerprint_info = {
        fingerprint: params[:fingerprint],
        device_info: params[:device_info],
        os_info: params[:os_info],
        timezone: params[:timezone],
        ip: request.remote_ip
      }

      session = sign_in(user_data: user_data, fingerprint_info: fingerprint_info)
      session.touch_last_seen_at

      redirect_back_or_to root_path, notice: "Successfully logged in!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy_all
    sign_out_of_all_sessions
    redirect_to profile_path, notice: "All other sessions have been signed out."
  end

  def destroy
    session_id = params[:id]

    if session_id == "current"
      sign_out
      redirect_to root_path, notice: "You have been successfully signed out."
    else
      # Find the session by ID directly using User::Session model
      # First, get the pd_id from the current session
      pd_id = current_session&.pd_id

      if pd_id
        # Find the session belonging to the current user's pd_id
        session = UserSession.where(pd_id: pd_id).find_by(id: session_id)

        if session
          session.update(signed_out_at: Time.current, expiration_at: Time.current)
          redirect_to profile_path, notice: "Session has been revoked."
        else
          redirect_to profile_path, alert: "Session not found."
        end
      else
        sign_out
        redirect_to root_path, alert: "Your session has expired. Please sign in again."
      end
    end
  end

  private

  def redirect_back_or_to(default, options = {})
    redirect_to(session[:return_to] || default, options)
    session.delete(:return_to)
  end

end
