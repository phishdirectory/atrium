# app/models/user/session.rb
class User::Session < ApplicationRecord
  has_paper_trail skip: [:session_token_ciphertext, :session_token_bidx]

  belongs_to :user
  belongs_to :impersonated_by, class_name: "User", optional: true

  # Encryption and blind indexing
  has_encrypted :session_token
  blind_index :session_token

  # Scopes
  scope :impersonated, -> { where.not(impersonated_by_id: nil) }
  scope :not_impersonated, -> { where(impersonated_by_id: nil) }
  scope :expired, -> { where("expiration_at <= ?", Time.current) }
  scope :not_expired, -> { where("expiration_at > ?", Time.current) }
  scope :signed_out, -> { where.not(signed_out_at: nil) }
  scope :not_signed_out, -> { where(signed_out_at: nil) }
  scope :active, -> { not_expired.not_signed_out }
  scope :recently_expired_within, ->(date) { expired.where("expiration_at >= ?", date) }

  # Location tracking
  extend Geocoder::Model::ActiveRecord
  geocoded_by :ip
  after_validation :geocode, if: ->(session){ session.ip.present? && session.ip_changed? }

  # Methods
  def impersonated?
    impersonated_by.present?
  end

  def expired?
    expiration_at <= Time.current
  end

  def active?
    !expired? && signed_out_at.nil?
  end

  LAST_SEEN_AT_COOLDOWN = 5.minutes

  def touch_last_seen_at
    return if last_seen_at&.after?(LAST_SEEN_AT_COOLDOWN.ago)

    update_columns(last_seen_at: Time.current)
  end

  # Method to find session by token directly without using blind_index
  def self.find_by_token(token)
    # This is a fallback method to find sessions directly
    # Not recommended for production use
    all.find { |session| session.session_token == token }
  end

  # Modified current_session method for the sessions_helper.rb
  # Add this method to the sessions_helper.rb
  def self.find_current_session(token)
    return nil if token.nil?

    # Try to find by direct comparison as a fallback
    session = find_by_token(token)

    return session if session&.active?

    nil
  end

end
