# app/controllers/admin_controller.rb
# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user
  before_action :require_admin

  layout "admin"

  def index
  end

  private

  def authenticate_user
    redirect_to login_path, alert: "Please log in to access the admin area." unless current_user
  end

  def require_admin
    redirect_to root_path, alert: "You don't have permission to access this area." unless current_user&.admin?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

end
