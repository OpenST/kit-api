class ApiCredential < DbConnection::KitSaasSubenv
  include Util::ResultHelper

  after_commit :flush_cache

  class << self

    def generate_encrypted_secret_key(salt)

      api_secret = Digest::SHA256.hexdigest SecureRandom.hex(12)

      encryptor_obj = LocalCipher.new(salt)
      r = encryptor_obj.encrypt(api_secret)
      return r unless r.success?

      success_with_data(r.data[:ciphertext_blob])

    end

    def generate_api_key
      SecureRandom.hex(16)
    end

  end

  scope :non_expired_for_client, ->(client_id) {
    where('client_id = ? AND (expiry_timestamp > ? OR expiry_timestamp IS NULL)', client_id, Time.now.to_i)
  }

  def flush_cache
    KitSaasSharedCacheManagement::ApiCredentials.new([client_id]).clear([api_key])
  end

end
