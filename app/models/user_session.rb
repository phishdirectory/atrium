# frozen_string_literal: true

# app/models/user_session.rb
# == Schema Information
#
# Table name: user_sessions
#
#  id                       :bigint           not null, primary key
#  device_info              :string
#  expiration_at            :datetime         not null
#  fingerprint              :string
#  ip                       :string
#  last_seen_at             :datetime
#  latitude                 :float
#  longitude                :float
#  os_info                  :string
#  session_token_bidx       :string
#  session_token_ciphertext :string
#  signed_out_at            :datetime
#  string                   :string
#  timezone                 :string
#  user_data_ciphertext     :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  pd_id                    :string           not null
#
# Indexes
#
#  index_user_sessions_on_pd_id  (pd_id)
#
class UserSession < ApplicationRecord
  has_encrypted :session_token
  blind_index :session_token
  has_encrypted :user_data, type: :json

  scope :expired, -> { where("expiration_at <= ?", Time.zone.now) }
  scope :not_expired, -> { where("expiration_at > ?", Time.zone.now) }
  scope :recently_expired_within, ->(date) { expired.where("expiration_at >= ?", date) }

  extend Geocoder::Model::ActiveRecord
  geocoded_by :ip
  after_validation :geocode, if: ->(session){ session.ip.present? and session.ip_changed? }

  LAST_SEEN_AT_COOLDOWN = 5.minutes

  def touch_last_seen_at
    return if last_seen_at&.after? LAST_SEEN_AT_COOLDOWN.ago # prevent spamming writes

    update_columns(last_seen_at: Time.zone.now)
  end

  def expired?
    expiration_at <= Time.zone.now
  end

  # Helper methods to access user data
  def pd_id
    user_data["pd_id"]
  end

  def email
    user_data["email"]
  end

  def first_name
    user_data["first_name"]
  end

  def last_name
    user_data["last_name"]
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def access_level
    user_data["permissions"]["global_access_level"]["name"]
  end

  def access_level_value
    user_data["permissions"]["global_access_level"]["value"]
  end

  def admin?
    access_level_value >= 2
  end

end
