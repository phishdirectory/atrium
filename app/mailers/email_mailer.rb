class EmailMailer < ApplicationMailer
  default from: "noreply@mail.phish.directory"

  def outbound_email(email)
    @email = email
    @user = email.user

    # Set email headers for threading
    headers["Message-ID"] = @email.message_id
    headers["In-Reply-To"] = @email.in_reply_to if @email.in_reply_to.present?
    headers["References"] = @email.references if @email.references.present?

    mail(
      from: @email.sender,
      to: @email.recipient,
      subject: @email.subject
    )
  end

end
