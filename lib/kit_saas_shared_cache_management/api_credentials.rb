module KitSaasSharedCacheManagement

  class ApiCredentials < KitSaasSharedCacheManagement::Base

    # Fetch from cache and for cache misses call fetch_from_db
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def fetch

      encrypted_data_from_cache = super

      decrypted_data_from_cache = {}

      # as cache has local cypher encrypted value of API Secret, we would need to decrypt it before sending it out
      encrypted_data_from_cache.each do |client_id, api_credentials|

        decrypted_api_credentials = []

        api_credentials.each do |api_credential|

          r = encryptor_obj.decrypt(api_credential[:api_secret])

          if r.success?
            decrypted_api_credentials.push(
              id: api_credential[:id],
              api_secret: r.data[:plaintext],
              api_key: api_credential[:api_key],
              expiry_timestamp: api_credential[:expiry_timestamp]
            )
          else
            fail OstCustomError.new(r)
            #decrypted_data_from_cache[client_id] = {}
          end

        end

        decrypted_data_from_cache[client_id] = decrypted_api_credentials

      end

      decrypted_data_from_cache

    end

    # Clear cache
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    def clear(affected_api_keys)

      super()

      affected_api_keys.each do |affected_api_key|
        # delete cache key set by saas which has secret key for given secret key
        Memcache.delete_from_all_instances("#{GlobalConstant::Cache.saas_key_prefix}_#{GlobalConstant::Cache.key_prefixes_template_vars[:saas_subenv]}_cs_#{affected_api_key.downcase}")
      end

      nil

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

        get_credentials_rsp = FetchDecryptedApiCredentials.new(client_id: client_id).perform
        return get_credentials_rsp unless get_credentials_rsp.success?

        api_credentials = get_credentials_rsp.data[:api_credentials]

        cache_data = []

        api_credentials.each do |api_credential|

          encrypt_rsp = encryptor_obj.encrypt(api_credential[:api_secret])
          return encrypt_rsp unless encrypt_rsp.success?

          cache_data.push(
              {
                  id: api_credential[:id],
                  api_key: api_credential[:api_key],
                  api_secret: encrypt_rsp.data[:ciphertext_blob],
                  expiry_timestamp: api_credential[:expiry_timestamp]
              }
          )

        end

        aggregated_cache_data[client_id] = cache_data

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
      @m_k_o ||= MemcacheKey.new('client.api_credentials')
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