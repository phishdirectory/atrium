# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id          :bigint           not null, primary key
#  archived    :boolean          default(FALSE)
#  in_reply_to :string
#  read        :boolean          default(FALSE)
#  received_at :datetime
#  recipient   :string           not null
#  references  :string
#  sender      :string           not null
#  sent_at     :datetime
#  starred     :boolean          default(FALSE)
#  subject     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mailbox_id  :bigint           not null
#  message_id  :string
#
# Indexes
#
#  index_emails_on_in_reply_to  (in_reply_to)
#  index_emails_on_mailbox_id   (mailbox_id)
#  index_emails_on_message_id   (message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (mailbox_id => mailboxes.id)
#
class Email < ApplicationRecord
  belongs_to :mailbox
  has_one :user, through: :mailbox

  has_rich_text :body

  validates :subject, presence: true
  validates :sender, presence: true
  validates :recipient, presence: true

  scope :inbox, -> { where.not(received_at: nil).order(received_at: :desc) }
  scope :sent, -> { where.not(sent_at: nil).order(sent_at: :desc) }
  scope :unread, -> { where(read: false) }

  def mark_as_read!
    update(read: true)
  end

  def mark_as_unread!
    update(read: false)
  end

end
