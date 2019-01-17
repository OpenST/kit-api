module WalletAddressesManagement
  class GetAddresses < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [WalletAddressesManagement::GetAddresses]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]

      @api_response_data = {}

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

        #r = validate_and_sanitize
        #return r unless r.success?

        #Check if the given address is associated in db
        #r = fetch_addresses
        #return r unless r.success?



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
      @client_id = @client_id.to_i

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

    end
  end
end