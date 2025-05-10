# frozen_string_literal: true

# == Schema Information
#
# Table name: mailboxes
#
#  id            :bigint           not null, primary key
#  email_address :string           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  profile_id    :bigint           not null
#
# Indexes
#
#  index_mailboxes_on_email_address  (email_address) UNIQUE
#  index_mailboxes_on_profile_id     (profile_id)
#
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
