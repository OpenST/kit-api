module WalletAddressesManagement
  class CreateOSTManagedAddress < WalletAddressesManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    #
    # @return [WalletAddressesManagement::CreateOSTManagedAddress]
    #
    def initialize(params)
      super

      @client_id = params[:client_id]
    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_token_details
        return r unless r.success?

        r = check_token_status
        return r unless r.success?

        r = fetch_token_owner_address
        return r unless r.success?

        r = perform_address_update
        return r unless r.success?

        return_addresses_entity

      end

    end

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      @client_id = @client_id.to_i

      #check environment
      if GlobalConstant::Base.environment_name == GlobalConstant::Environment.production_environment
        return validation_error(
          'a_s_wam_coma_1',
          'unauthorized_access_response',
          [],
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Check token status
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def check_token_status

      #check if token setup is not deployed or completely failed
      if @token[:status] != GlobalConstant::ClientToken.not_deployed && @token[:status] != GlobalConstant::ClientToken.deployment_failed
        return validation_error(
          'a_s_wam_coma_2',
          'token_status_invalid',
          [],
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Perform the address update  if necessary
    #
    #
    # * Author: Ankit
    # * Date: 24/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def perform_address_update

      properties = @token[:properties].present? ? Token.get_bits_set_for_properties(@token[:properties]) : []
      if @owner_address.nil? || properties.exclude?(GlobalConstant::ClientToken.has_ost_managed_owner)

        r = request_saas_for_new_address
        return r unless r.success?

        update_token_owner_addresses
        update_client_wallet_address
        update_token_properties
      end
      success
    end

    # Request Saas to get a new known address
    #
    #
    # * Author: Ankit
    # * Date: 24/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def request_saas_for_new_address

      r = SaasApi::WalletAddress::Generate.new.perform
      return r unless r.success?

      @new_known_address = r.data[:address].downcase
      @address_known_id = r.data[:knownAddressId]

      @owner_address = @new_known_address
      success
    end

    # Update token owner address in token addresses table
    #
    #
    # * Author: Ankit
    # * Date: 24/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def update_token_owner_addresses
      token_address = TokenAddresses.where(token_id: @token_id, kind: GlobalConstant::TokenAddresses.owner_address_kind).first_or_initialize
      token_address[:address] = @new_known_address
      token_address[:known_address_id] = @address_known_id

      token_address.save!

    end

    # Update token owner address in client wallet address
    #
    #
    # * Author: Ankit
    # * Date: 24/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def update_client_wallet_address
      client_address = ClientWalletAddress.where(client_id: @client_id).first_or_initialize
      client_address[:address] = @new_known_address
      client_address[:sub_environment] = GlobalConstant::Base.sub_environment_name
      client_address[:status] = GlobalConstant::WalletAddressStatus.active_status

      client_address.save!
    end

    # Update token properties. Mark the token as has_ost_managed_owner
    #
    #
    # * Author: Ankit
    # * Date: 24/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def update_token_properties

      @token.send("set_#{GlobalConstant::ClientToken.has_ost_managed_owner}")

      @token.save!
    end
  end
end