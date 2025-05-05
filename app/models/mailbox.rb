# frozen_string_literal: true

class Mailbox < ApplicationRecord
  belongs_to :user
  has_many :emails, dependent: :destroy

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  # Generate email address based on username
  before_validation :set_email_address, on: :create

  private

  def set_email_address
    return if email_address.present?

    username = user.email.split("@").first.downcase.gsub(/[^a-z0-9]/, "")
    self.email_address = "#{username}@mail.phish.directory"
  end

end
