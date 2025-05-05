# frozen_string_literal: true

class User < ApplicationRecord
  # has_paper_trail
  has_secure_password

  enum :access_level, {
    user: 0,
    admin: 1
  }, default: :user, null: false

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  scope :user, -> { where(access_level: %i[user admin]) }
  scope :admin, -> { where(access_level: :admin) }

  scope :last_seen_within, ->(ago) { joins(:user_sessions).where(user_sessions: { last_seen_at: ago.. }).distinct }
  scope :currently_online, -> { last_seen_within(15.minutes.ago) }
  scope :active, -> { last_seen_within(30.days.ago) }
  def active? = last_seen_at && (last_seen_at >= 30.days.ago)


  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    ["admin"].include?(self.access_level) && !self.pretend_is_not_admin
  end

  def admin_override_pretend?
    ["admin"].include?(self.access_level)
  end

  def make_admin!
    admin!
  end

  def remove_admin!
    user!
  end

  def last_seen_at
    user_sessions.maximum(:last_seen_at)
  end

  def last_login_at
    user_sessions.maximum(:created_at)
  end

  private

end
