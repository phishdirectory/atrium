# frozen_string_literal: true

# config/initializers/blind_index.rb
require "blind_index"

# Generate a secure key for blind index (32 bytes / 64 hex chars)
# In production, this should come from environment variables or credentials
BlindIndex.master_key = Rails.application.credentials.dig(:blind_index, :master_key) ||
                        SecureRandom.hex(32)
