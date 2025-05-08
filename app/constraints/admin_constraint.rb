# frozen_string_literal: true

# app/constraints/admin_constraint.rb
class AdminConstraint
  def matches?(request)
    return false unless request.session[:pd_id]

    # Get the session token from cookies
    session_token = request.cookie_jar.encrypted[:session_token]
    return false unless session_token

    # Find the session
    session = UserSession.not_expired.find_by(session_token: session_token)
    return false unless session

    # Check if the user is an admin
    session.admin?
  end

end
