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

        r = create_entries
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
        message_to_sign: GlobalConstant::MessageToSign.wallet_association
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

    # Creates entry in client wallet addresses and token addresses
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]

    def create_entries

      ClientWalletAddress.create!(
        client_id: @client_id,
        sub_environment: GlobalConstant::Environment.url_prefix,
        address: @owner_address,
        status:GlobalConstant::WalletAddressStatus.active_status
      )

      token_details = CacheManagement::TokenDetails.new([@client_id]).fetch || {}
      token_id = token_details[@client_id][:id]

      TokenAddresses.create!(
        token_id: token_id,
        chain_kind: GlobalConstant::TokenAddresses.aux,
        kind: GlobalConstant::TokenAddresses.owner,
        address: @owner_address
      )

      TokenAddresses.create!(
        token_id: token_id,
        chain_kind: GlobalConstant::TokenAddresses.origin,
        kind: GlobalConstant::TokenAddresses.owner,
        address: @owner_address
      )

      success
    end

  end
end