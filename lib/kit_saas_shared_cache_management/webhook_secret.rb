module KitSaasSharedCacheManagement

  class WebhookSecret < KitSaasSharedCacheManagement::Base

    # Fetch from cache and for cache misses call fetch_from_db
    #
    # * Author: Alpesh
    # * Date: 07/06/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def fetch

      encrypted_data_from_cache = super

      decrypted_data_from_cache = {}
      # as cache has local cypher encrypted value of API Secret, we would need to decrypt it before sending it out
      encrypted_data_from_cache.each do |client_id, secrets|

        decrypted_api_credentials = {}

        if(secrets.present?)
          r = encryptor_obj.decrypt(secrets[:webhook_secret])

          if r.success?
            decrypted_api_credentials[:webhook_secret] = r.data[:plaintext]
          else
            fail OstCustomError.new(r)
          end

          if secrets[:grace_expiry_at].present? && secrets[:webhook_grace_secret].present?
            decrypted_api_credentials[:grace_expiry_at] = secrets[:grace_expiry_at]

            r = encryptor_obj.decrypt(secrets[:webhook_grace_secret])

            if r.success?
              decrypted_api_credentials[:webhook_grace_secret] = r.data[:plaintext]
            else
              fail OstCustomError.new(r)
            end
          end
        end

        decrypted_data_from_cache[client_id] = decrypted_api_credentials

      end

      decrypted_data_from_cache

    end

    private

    # Fetch from db
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_from_db(cache_miss_ids)

      aggregated_cache_data = {}

      cache_miss_ids.each do |client_id|

        get_secrets_rsp = ::WebhookSecrets::FetchDecrypted.new(client_id: client_id).perform
        next unless get_secrets_rsp.success?

        webhook_secrets = get_secrets_rsp.data

        encrypt_rsp = encryptor_obj.encrypt(webhook_secrets[:webhook_secret])
        return encrypt_rsp unless encrypt_rsp.success?

        webhook_secrets[:webhook_secret] = encrypt_rsp.data[:ciphertext_blob]

        if webhook_secrets[:grace_expiry_at].present? && webhook_secrets[:webhook_grace_secret].present?
          encrypt_rsp = encryptor_obj.encrypt(webhook_secrets[:webhook_grace_secret])
          return encrypt_rsp unless encrypt_rsp.success?

          webhook_secrets[:webhook_grace_secret] = encrypt_rsp.data[:ciphertext_blob]

          expiry_delta = (Time.now.to_i - webhook_secrets[:grace_expiry_at])
          if expiry_delta > 0 && expiry_delta < memcache_key_object.expiry
            memcache_key_object.expiry = expiry_delta
          end
        end

        aggregated_cache_data[client_id] = webhook_secrets

      end

      success_with_data(aggregated_cache_data)

    end

    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [MemcacheKey]
    #
    def memcache_key_object
      @m_k_o ||= MemcacheKey.new('client.webhook_secret')
    end

    # Fetch cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_kit_cache_key(id)
      generate_kit_cache_key @options.merge(id: id)
    end

    # Fetch saas cache key
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [String]
    #
    def get_saas_cache_key(id)
      nil # generate_saas_cache_key @options.merge(id: id)
    end

    # Fetch cache expiry (in seconds)
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def get_cache_expiry
      memcache_key_object.expiry
    end

    # object which encrypts / decrypts
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [LocalCipher]
    #
    def encryptor_obj
      @e_obj ||= LocalCipher.new(GlobalConstant::SecretEncryptor.cache_data_sha_key)
    end

  end

end