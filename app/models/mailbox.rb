# frozen_string_literal: true

class Mailbox < ApplicationRecord
  belongs_to :profile
  has_many :emails, dependent: :destroy

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  # Generate email address based on username
  before_validation :set_email_address, on: :create

  private

  def set_email_address
    return if email_address.present?

    # username is first letter of first name and entire last name
    username = "#{profile.first_name[0].downcase}#{profile.last_name.downcase}"
    self.email_address = "#{username}@mail.phish.directory"
  end

end
