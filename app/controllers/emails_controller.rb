# frozen_string_literal: true

# app/controllers/emails_controller.rb
class EmailsController < ApplicationController
  before_action :authenticate_user
  before_action :set_email, only: [:show, :update, :destroy, :mark_read, :mark_unread, :star, :unstar, :archive, :unarchive]

  def index
    @folder = params[:folder] || "inbox"

    @emails = case @folder
              when "inbox"
                current_user.emails.where.not(received_at: nil).where(archived: false).order(received_at: :desc).includes(:rich_text_body)
              when "sent"
                current_user.emails.where.not(sent_at: nil).order(sent_at: :desc).includes(:rich_text_body)
              when "starred"
                current_user.emails.where(starred: true).order(created_at: :desc).includes(:rich_text_body)
              when "archived"
                current_user.emails.where(archived: true).order(created_at: :desc).includes(:rich_text_body)
              else
                current_user.emails.where.not(received_at: nil).where(archived: false).order(received_at: :desc).includes(:rich_text_body)
              end

    # If there's an ID param, find that specific email
    if params[:id].present?
      @email = current_user.emails.find_by(id: params[:id])
    end

    # If no email is selected yet, use the first one
    @email ||= @emails.first if @emails.any?

    # Load conversation for the selected email
    if @email&.message_id.present?
      @conversation = current_user.emails
                                  .where("message_id = ? OR in_reply_to = ? OR \"references\" LIKE ?",
                                         @email.message_id,
                                         @email.message_id,
                                         "%#{@email.message_id}%")
                                  .order(created_at: :asc)
    end

    # Mark as read if it's an incoming email and not already read
    if @email&.received_at.present? && !@email&.read?
      @email.update(read: true)
    end

    # Support pagination if Kaminari is available
    @emails = @emails.page(params[:page]).per(20) if defined?(Kaminari)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    # Mark as read if it's an incoming email and not already read
    @email.update(read: true) if @email.received_at.present? && !@email.read?

    # Load conversation thread if any
    if @email.message_id.present?
      # Use proper quoting for the 'references' column name
      @conversation = current_user.emails
                                  .where("message_id = ? OR in_reply_to = ? OR \"references\" LIKE ?",
                                         @email.message_id,
                                         @email.message_id,
                                         "%#{@email.message_id}%")
                                  .order(created_at: :asc)
    else
      @conversation = []
    end

    # Respond to different formats
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @email = Email.new

    # Handle reply
    return unless params[:reply_to]

    original = current_user.emails.find(params[:reply_to])
    @email.subject = "Re: #{original.subject}" unless original.subject.start_with?("Re:")
    @email.recipient = original.sender
    @email.in_reply_to = original.message_id
    @email.references = [original.references, original.message_id].compact.join(" ")
  end

  def create
    @email = current_user.mailbox.emails.new(email_params)
    @email.sender = current_user.mailbox.email_address
    @email.message_id = "<#{SecureRandom.uuid}@mail.phish.directory>"
    @email.sent_at = Time.current

    if @email.save
      # Send the actual email
      EmailMailer.outbound_email(@email).deliver_later

      redirect_to emails_path, notice: "Email was successfully sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @email.update(email_params)
      redirect_to @email, notice: "Email was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @email.destroy

    respond_to do |format|
      format.html { redirect_to emails_path, notice: "Email was successfully deleted." }
      format.turbo_stream { redirect_to emails_path, notice: "Email was successfully deleted." }
    end
  end

  def mark_read
    @email.update(read: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  def mark_unread
    @email.update(read: false)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  def star
    @email.update(starred: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  def unstar
    @email.update(starred: false)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  def archive
    @email.update(archived: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  def unarchive
    @email.update(archived: false)

    respond_to do |format|
      format.html { redirect_back(fallback_location: emails_path) }
      format.turbo_stream { head :ok }
    end
  end

  private

  def set_email
    @email = current_user.emails.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Email not found."
    redirect_to emails_path
  end

  def email_params
    params.require(:email).permit(:subject, :recipient, :body, :in_reply_to, :references)
  end

end
