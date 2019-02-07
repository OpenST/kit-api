module ApiCredentials

  class Create

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Puneet
    # * Date: 21/01/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) -  client id
    #
    # @return [ApiCredentials::Create]
    #
    def initialize(params)
      @client_id = params[:client_id]
    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    def perform

      r = validate_and_sanitize
      return r unless r.success?

      return success unless is_new_key_required?

      r = create_and_insert_new_keys
      return r unless r.success?

      success

    end

    # Validate and sanitize given parameters
    #
    # * Author: Ankit
    # * Date: 05/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      return validation_error(
        'l_ac_c_1',
        'invalid_api_params',
        ['invalid_client_id'],
        GlobalConstant::ErrorAction.default
      ) unless Util::CommonValidator.is_integer?(@client_id)

      @client_id = @client_id.to_i

      client = CacheManagement::Client.new([@client_id]).fetch[@client_id]

      return validation_error(
        'l_ac_c_2',
        'invalid_api_params',
        ['invalid_client_id'],
        GlobalConstant::ErrorAction.default
      ) unless client.present?

      #Checks if the client is allowed to access main sub env.
      return validation_error(
        'l_ac_c_3',
        'unauthorized_to_access_main_env',
        ['invalid_client_id'],
        GlobalConstant::ErrorAction.default
      ) if GlobalConstant::Base.main_sub_environment? && (client[:mainnet_statuses].exclude?(GlobalConstant::Client.mainnet_whitelisted_status))

      success
    end


    # This function check if any key is already present for given client id.
    #
    # Returns true if no key is present in db.
    # Return false if 1 or more than 1 keys are present in db
    #
    # * Author: Ankit
    # * Date: 05/02/2019
    # * Reviewed By:
    #
    def is_new_key_required?
      api_credentials = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
      api_credentials.length == 0
    end

    # Generate and insert new keys in table
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def create_and_insert_new_keys

      r = generate_api_key_salt
      return r unless r.success?
      api_salt = r.data

      r = ApiCredential.generate_encrypted_secret_key(api_salt[:plaintext])
      return r unless r.success?
      api_secret = r.data

      api_credential = ApiCredential.new(
        client_id: @client_id,
        api_key: ApiCredential.generate_api_key,
        api_secret: api_secret,
        api_salt: api_salt[:ciphertext_blob]
      )

      api_credential.save!

      success
    end

    private

    # Generate Api Key salt
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def generate_api_key_salt
      Aws::Kms.new(GlobalConstant::Kms.api_key_purpose, GlobalConstant::Kms.user_role).generate_data_key
    end

  end

end