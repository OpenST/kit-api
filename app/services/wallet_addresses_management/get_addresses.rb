module WalletAddressesManagement
  class GetAddresses < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [WalletAddressesManagement::GetAddresses]
    #
    def initialize(params)

      super

      @client_id = params[:client_id]

      @api_response_data = {}

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

        r = fetch_addresses
        return r unless r.success?

        r = format_response_data(r.data)
        return r unless r.success?

        success_with_data(@api_response_data)

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

      unless Util::CommonValidator.is_integer?(@client_id)
        return validation_error(
          'ga_vea_1',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      @token_details = CacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]

      if @token_details.blank?
        return validation_error(
          'ga_vea_2',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end


    def fetch_addresses
      @token_id = @token_details[:id]
      data_from_cache = CacheManagement::TokenAddresses.new([@token_id]).fetch
      success_with_data(data_from_cache)
    end

    def format_response_data(addresses_data)
      addresses = {}
      addresses[:whitelisted] = addresses_data[@token_id][GlobalConstant::TokenAddresses.owner_address_kind] ||= []
      addresses[:workers] = addresses_data[@token_id][GlobalConstant::TokenAddresses.worker_address_kind] ||= []
      addresses[:owner] = addresses_data[@token_id][GlobalConstant::TokenAddresses.owner_address_kind]
      addresses[:admin] = addresses_data[@token_id][GlobalConstant::TokenAddresses.admin_address_kind]

      sign_messages = {
        wallet_association: GlobalConstant::MessageToSign.wallet_association
      }

      @api_response_data[:origin_addresses] = addresses
      @api_response_data[:auxiliary_addresses] = addresses
      @api_response_data[:sign_messages] = sign_messages

      success

    end
  end
end