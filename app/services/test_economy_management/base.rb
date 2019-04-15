module TestEconomyManagement

  class Base < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client (mandatory) - Client cache data
    # @params [Hash] manager (mandatory) - Manager cache data
    # @params [String] auth_token (optional) - auth token to allow logged in user in main env to access test economy
    #
    # @return [TestEconomyManagement::Base]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @client = @params[:client]
      @manager = @params[:manager]
      @auth_token = @params[:auth_token]

      @token = nil
      @token_id = nil
      @aux_chain_id = nil

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      r = validate_access
      return r unless r.success?

      success

    end

    # Check is Test Economy Activation is allowed for this Economy
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def validate_access

      return success if GlobalConstant::Base.sandbox_sub_environment?

      return success if GlobalConstant::Base.activate_test_economy_auth_token.present? &&
          @auth_token == GlobalConstant::Base.activate_test_economy_auth_token

      error_with_data(
          'tem_b_1',
          'unauthorized_to_perform_action',
          GlobalConstant::ErrorAction.default
      )

    end

    # Check if request is to mainnet ENV
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def is_main_sub_env?
      GlobalConstant::Base.main_sub_environment?
    end

    # Check if is already registered in mappy server
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def registered_in_mappy_server?
      is_main_sub_env? ? @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_registered_in_mappy_server_status) :
          @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status)
    end

    # Check if QR code has already been uploaded
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Boolean]
    #
    def test_economy_qr_code_uploaded?
      is_main_sub_env? ? @client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status) :
          @client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status)
    end

    # Find & validate token
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # Sets @token, @token_id
    #
    # @return [Result::Base]
    #
    def fetch_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tem_b')
      return token_resp unless token_resp.success?

      @token = token_resp.data

      # if token is not yet deployed, per its status redirect accordingly
      if @token[:status] != GlobalConstant::ClientToken.deployment_completed
        return error_with_data(
            'tem_b_2',
            'token_not_setup',
            GlobalConstant::ErrorAction.default
        )
      end

      @token_id = @token[:id]
      @aux_chain_id = @token[:aux_chain_id]

      success

    end

    # fetch the sub env response data entity
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_payloads
      r = SubEnvPayload.new({client_id: @client_id}).perform
      return r unless r.success?

      @sub_env_payloads = r.data[:sub_env_payloads]

      success
    end

    # Url id
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def url_id
      @url_id ||= begin
        string_to_sign = "#{GlobalConstant::Base.environment_name}-#{GlobalConstant::Base.sub_environment_name}-#{@token_id}-#{@client_id}-#{@aux_chain_id}"
        OpenSSL::HMAC.hexdigest("SHA256",
                                GlobalConstant::Base.activate_test_economy_auth_token, string_to_sign)
      end
    end

    # Get mappy api endpoint
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def mappy_api_endpoint
      @mappy_api_endpoint ||= "#{GlobalConstant::DemoMappyServer.api_endpoint}/#{@token_id}/#{url_id}/"
    end

    # Generate QR Code file S3 Path
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def qr_code_s3_file_path
      "#{GlobalConstant::S3.test_economy_qr_code_folder}/#{@aux_chain_id}/#{url_id}.png"
    end

    # S3 URL for QR Code
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [String]
    #
    def qr_code_s3_url
      GlobalConstant::S3.public_asset_s3_url(qr_code_s3_file_path)
    end

  end

end
