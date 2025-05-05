# frozen_string_literal: true

class IncomingMailbox < ApplicationMailbox
  def process
    # Extract email address, subject, body, etc.
    recipient_email = mail.to.first.downcase
    sender_email = mail.from.first.downcase
    subject = mail.subject
    body_content = extract_body
    message_id = mail.message_id
    in_reply_to = mail.in_reply_to
    references = mail.references&.join(" ")

    # Find the mailbox for this recipient
    mailbox = Mailbox.find_by(email_address: recipient_email)

    if mailbox.nil?
      # Handle case where mailbox doesn't exist
      # Maybe bounce the email or send to a default mailbox
      Rails.logger.error "No mailbox found for: #{recipient_email}"
      return
    end

    # Create a new email in the mailbox
    mailbox.emails.create!(
      subject: subject,
      sender: sender_email,
      recipient: recipient_email,
      body: body_content,
      received_at: Time.current,
      message_id: message_id,
      in_reply_to: in_reply_to,
      references: references
    )
  end

  private

  def extract_body
    if mail.multipart?
      # Try to get HTML part first, then fall back to text part
      mail.html_part&.decoded || mail.text_part&.decoded || mail.body.decoded
    else
      mail.body.decoded
    end
  end

end
