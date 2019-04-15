module WalletAddressesManagement
  class AssociateAddress < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (mandatory) - logged in client manager object
    # @params [String] owner_address (mandatory) - owner address
    # @params [String] personal_sign (mandatory) - Sign to verify
    #
    # @return [WalletAddressesManagement::AssociateAddress]
    #
    def initialize(params)
      super

      @client_id = @params[:client_id]
      @client_manager = @params[:client_manager]
      @owner_address = @params[:owner]
      @personal_sign = @params[:personal_sign]

      @isRequestFromSameClient = false
      @signed_by_address = nil

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        #Check if the given address is associated in db
        r = is_address_available_check
        return r unless r.success?

        #This check is added for a scenario when same client calls the associate address more than once.
        if @isRequestFromSameClient
          return success_with_data({
                                     origin_addresses: @origin_addresses,
                                     auxiliary_addresses: @auxiliary_addresses
                                   })
        end

        r = redirect_request_to_saas_api
        return r unless r.success?

        r = verify_signer
        return r unless r.success?

        r = create_entries
        return r unless r.success?

        success_with_data({
                            origin_addresses: @origin_addresses,
                            auxiliary_addresses: @auxiliary_addresses
                          })

      end

    end

    private

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
      @owner_address = sanitize_address(@owner_address)
      @client_id = @client_id.to_i

      unless Util::CommonValidator.is_ethereum_address?(@owner_address)
        return validation_error(
          's_wam_aa_1',
          'invalid_api_params',
          ['invalid_owner_address'],
          GlobalConstant::ErrorAction.default
        )
      end

      @token_details = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]

      if @token_details.blank?
        return validation_error(
          's_wam_aa_2',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @origin_addresses = {owner_address: @owner_address, admin: '', whitelisted: [], workers: []}
      @auxiliary_addresses = {owner_address: @owner_address, admin: '', whitelisted: [], workers: []}

      success

    end

    # validate
    #
    # * Author: Kedar
    # * Date: 22/02/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def validate
      r = super
      return r unless r.success?

      r = ManagerManagement::Team::CheckSuperAdminRole.new(
        {client_manager: @client_manager}).perform

      unless r.success?
        return error_with_data(
          's_wam_aa_3',
          'unauthorized_to_perform_action',
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Redirect request to saas api
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def redirect_request_to_saas_api
      params_for_saas_api = {
        signer: @owner_address,
        personal_sign: @personal_sign,
        message_to_sign: GlobalConstant::MessageToSign.wallet_association,
        client_id: @client_id
      }

      r = SaasApi::WalletAddress::Associate.new.perform(params_for_saas_api)
      return r unless r.success?

      @signed_by_address = r.data[:signer]
      @signed_by_address = sanitize_address(@signed_by_address)
      success
    end

    # verify signer
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def verify_signer

      if @signed_by_address != @owner_address
        return validation_error(
          's_wam_aa_4',
          'unauthorized_access_response',
          ['invalid_signature'],
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # Is the given address already associated
    #
    # * Author: Ankit
    # * Date: 08/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def is_address_available_check

      clientWalletAddress = ClientWalletAddress.where('address = ?' , @owner_address).first

      if clientWalletAddress.present?
        if clientWalletAddress.client_id != @client_id || clientWalletAddress.sub_environment != GlobalConstant::Base.sub_environment_name
          return validation_error(
            's_wam_aa_5',
            'already_associated',
            ['already_associated_address'],
            GlobalConstant::ErrorAction.default
          )
        else
          @isRequestFromSameClient = true
          success
        end
      else
        success
      end
    end

    # Creates entry in client wallet addresses and token addresses
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]

    def create_entries

      #check if the same client has some address associated with it. Update the address if already present
      clientWalletAddress = ClientWalletAddress.where(client_id: @client_id, sub_environment: GlobalConstant::Base.sub_environment_name).first

      if clientWalletAddress.present?
        #update the new address
        clientWalletAddress.address = @owner_address
        clientWalletAddress.sub_environment = GlobalConstant::Base.sub_environment_name
        clientWalletAddress.save!
      else
        ClientWalletAddress.create!(
          client_id: @client_id,
          sub_environment: GlobalConstant::Base.sub_environment_name,
          address: @owner_address.downcase,
          status:GlobalConstant::WalletAddressStatus.active_status
        )
      end

      token_id = @token_details[:id]

      tokenAddresses = TokenAddresses.where('token_id = ?', token_id)

      if tokenAddresses.present?
        TokenAddresses.where(token_id: token_id, kind: GlobalConstant::TokenAddresses.owner_address_kind).update_all(address:@owner_address)
        KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).clear
      else
        TokenAddresses.create!(
          token_id: token_id,
          kind: GlobalConstant::TokenAddresses.owner_address_kind,
          address: @owner_address
        )

      end

      success
    end

  end
end