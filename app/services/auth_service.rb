# frozen_string_literal: true

# app/services/auth_service.rb
class AuthService
  if Rails.env.development?
    API_BASE_URL = "http://localhost:3000/api/v1"
  else
    API_BASE_URL = "https://veritas.phish.directory/api/v1"
  end

  # if Rails.application.credentials.dig(:veritas, :api_key) is  nil
  if Rails.application.credentials.dig(:veritas, :api_key).nil?
    raise "Veritas API key is missing. Please set it in the credentials."
  end

  if Rails.application.credentials.dig(:veritas, :hash_key).nil?
    raise "Veritas Hash key is missing. Please set it in the credentials."
  end

  API_KEY = Rails.application.credentials.dig(:veritas, :api_key)

  def self.authenticate(email, password)
    # Hash the credentials as required by the API
    hashed_credentials = hash_credentials(email, password)

    # Make the API request
    response = Faraday.post("#{API_BASE_URL}/auth/authenticate") do |req|
      req.headers["X-Api-Key"] = API_KEY
      req.headers["Content-Type"] = "application/json"
      req.body = { credentials: hashed_credentials }.to_json
    end

    # Parse the response
    result = JSON.parse(response.body) rescue nil

    return nil unless result && result["authenticated"] && result["pd_id"]

    # If authentication successful, get the user details
    get_user_data(result["pd_id"])

    # Return user data if available

  end

  def self.get_user_data(pd_id)
    response = Faraday.get("#{API_BASE_URL}/users/#{pd_id}") do |req|
      req.headers["X-Api-Key"] = API_KEY
      req.headers["Content-Type"] = "application/json"
    end

    JSON.parse(response.body) rescue nil
  end

  private

  def self.hash_credentials(email, password)
    # Create a hash of the credentials as required by the API
    credentials = { email: email, password: password }.to_json

    # Get the hash key from credentials
    hash_key = Rails.application.credentials.dig(:veritas, :hash_key)

    # Encrypt using AES-256-CBC
    cipher = OpenSSL::Cipher.new("aes-256-cbc")
    cipher.encrypt

    # Create key and iv from the hash_key
    key = Digest::SHA256.digest(hash_key)[0...32]
    iv = hash_key[0...16].ljust(16, "0")

    cipher.key = key
    cipher.iv = iv

    # Encrypt the data
    encrypted = cipher.update(credentials) + cipher.final

    # Return the encrypted data as base64
    Base64.strict_encode64(encrypted)
  end

end
