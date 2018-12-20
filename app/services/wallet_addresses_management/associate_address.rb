module WalletAddressesManagement
  class AssociateAddress < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @owner_address = @params[:owner_address]
      @personal_sign = @params[:personal_sign]

      @signed_by_address = nil

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = redirect_request_to_saas_api
        return r unless r.success?

        r = verify_signer
        return r unless r.success?

        r = associate
        return r unless r.success?

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 29/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      # sanitize
      @owner_address = @owner_address.to_s.strip.downcase

      unless Util::CommonValidator.is_ethereum_address?(@owner_address)
        return validation_error(
          'cm_vea_1',
          'invalid_api_params',
          ['invalid_eth_address'],
          GlobalConstant::ErrorAction.default
        )
      end

      client_token = CacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]

      if client_token.blank?
        return validation_error(
          'cm_vea_2',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @client_id = @client_id.to_i

      success

    end

    # Redirect request to saas api
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def redirect_request_to_saas_api
      params_for_saas_api = {
        signer: @owner_address,
        personal_sign: @personal_sign,
        message_to_sign: GlobalConstant::MessageToSign.message
      }

      r = SaasApi::WalletAddress::Associate.new.perform(params_for_saas_api)
      return r unless r.success?

      @signed_by_address = r.data[:signer]

      success
    end

    # verify signer
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def verify_signer

      if @signed_by_address != @owner_address
        return validation_error(
          'cm_vea_3',
          'unauthorized_access_response',
          ['invalid_signature'],
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # associate address. Creates entry in client wallet addresses table
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]

    def associate

      ClientWalletAddress.create!(
        client_id: @client_id,
        sub_environment: GlobalConstant::Environment.url_prefix,
        address: @owner_address,
        status:GlobalConstant::WalletAddressStatus.active_status
      )

      success
    end

  end
end