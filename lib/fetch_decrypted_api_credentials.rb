class FetchDecryptedApiCredentials

  include Util::ResultHelper

  # Initialize
  #
  # * Author: Puneet
  # * Date: 21/01/2019
  # * Reviewed By:
  #
  # @param [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
  #
  # @return [FetchDecryptedApiCredentials]
  #
  def initialize(params)
    @client_id = params[:client_id]
    @api_credentials = nil
    @response_data = {api_credentials: []}
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

    @api_credentials = ApiCredential.non_expired_for_client(@client_id).order('id ASC')

    return success_with_data(@response_data) if @api_credentials.length == 0

    r = decrypt_api_secrets
    return r unless r.success?

    success_with_data(@response_data)

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
          'fdac_1',
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
  def decrypt_api_secrets

    @api_credentials.each do |api_credential|

      r = Aws::Kms.new(GlobalConstant::Kms.api_key_purpose, GlobalConstant::Kms.user_role).decrypt(api_credential.api_salt)
      return r unless r.success?

      info_salt_d = r.data[:plaintext]

      r = LocalCipher.new(info_salt_d).decrypt(api_credential.api_secret)
      return r unless r.success?

      @response_data[:api_credentials].push(
        {
          id: api_credential.id,
          api_key: api_credential.api_key,
          api_secret: r.data[:plaintext],
          expiry_timestamp: api_credential.expiry_timestamp
        }
      )

    end

    success

  end

end