# frozen_string_literal: true

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
