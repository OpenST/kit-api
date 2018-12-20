module WalletAddressesManagement
  class IsAddressAvailable < ServicesBase

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
      @address = @params[:address]

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

        validate_and_sanitize

        is_address_available

        success_with_data(@api_response_data)

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validate

      success

    end

    # Is the given address available
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def is_address_available

      if ClientWalletAddress.where('address = ?' , @address).first.present?
        @api_response_data['is_address_available'] = true
      else
        @api_response_data['is_address_available'] = false
      end

    end
  end
end