# app/controllers/emails_controller.rb
class EmailsController < ApplicationController
  before_action :authenticate_user
  # Make sure set_email is called before the update action
  before_action :set_email, only: [:show, :update, :destroy, :mark_read, :mark_unread, :star, :unstar, :archive, :unarchive]

  def index
    @folder = params[:folder] || "inbox"

    @emails = case @folder
              when "inbox"
                current_user.emails.where.not(received_at: nil).order(received_at: :desc)
              when "sent"
                current_user.emails.where.not(sent_at: nil).order(sent_at: :desc)
              when "starred"
                current_user.emails.where(starred: true).order(created_at: :desc)
              when "archived"
                current_user.emails.where(archived: true).order(created_at: :desc)
              else
                current_user.emails.where.not(received_at: nil).order(received_at: :desc)
              end

    @emails = @emails.page(params[:page]).per(20) if defined?(Kaminari)
  end

  def show
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

  # Add this method which is referenced in before_action but was missing
  def update
    if @email.update(email_params)
      redirect_to @email, notice: "Email was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @email.destroy
    redirect_to emails_path, notice: "Email was successfully deleted."
  end

  def mark_read
    @email.update(read: true)
    redirect_back(fallback_location: emails_path)
  end

  def mark_unread
    @email.update(read: false)
    redirect_back(fallback_location: emails_path)
  end

  def star
    @email.update(starred: true)
    redirect_back(fallback_location: emails_path)
  end

  def unstar
    @email.update(starred: false)
    redirect_back(fallback_location: emails_path)
  end

  def archive
    @email.update(archived: true)
    redirect_back(fallback_location: emails_path)
  end

  def unarchive
    @email.update(archived: false)
    redirect_back(fallback_location: emails_path)
  end

  private

  # This is the callback method referenced in before_action
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
