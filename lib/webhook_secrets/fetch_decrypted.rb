module WebhookSecrets

  class FetchDecrypted

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Alpesh
    # * Date: 07/06/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
    #
    # @return [ApiCredentials::FetchDecrypted]
    #
    def initialize(params)
      @client_id = params[:client_id]
      @webhook_endpoint = nil
      @response_data = {}
      @webhook_secret = nil
      @webhook_grace_secret = nil
      @webhook_grace_secret_expiry_at = nil
    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      r = validate_and_sanitize
      return r unless r.success?

      @webhook_endpoint = WebhookEndpoint.where('client_id = ?', @client_id).first

      return error_with_data(
        'l_ws_fd_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
      ) if @webhook_endpoint.blank?

      r = decrypt_webhook_secrets
      return r unless r.success?

      success_with_data(
        webhook_secret: @webhook_secret,
        webhook_grace_secret: @webhook_grace_secret,
        grace_expiry_at: @webhook_grace_secret_expiry_at
      )

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      if @client_id.blank?
        return validation_error(
          'l_ws_fd_1',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # Decrypt secrets
    #
    # * Author: Puneet
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def decrypt_webhook_secrets

      r = Aws::Kms.new(GlobalConstant::Kms.api_key_purpose, GlobalConstant::Kms.user_role).decrypt(@webhook_endpoint.secret_salt)
      return r unless r.success?

      secret_salt_d = r.data[:plaintext]

      r = LocalCipher.new(secret_salt_d).decrypt(@webhook_endpoint.secret)
      return r unless r.success?

      @webhook_secret = r.data[:plaintext]

      if @webhook_endpoint.grace_secret && @webhook_endpoint.grace_expiry_at > Time.now.to_i
        r = LocalCipher.new(secret_salt_d).decrypt(@webhook_endpoint.grace_secret)
        return r unless r.success?

        @webhook_grace_secret_expiry_at = @webhook_endpoint.grace_expiry_at
        @webhook_grace_secret = r.data[:plaintext]
      end

      success

    end

  end

end