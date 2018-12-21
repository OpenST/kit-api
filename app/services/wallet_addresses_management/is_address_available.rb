module WalletAddressesManagement
  class IsAddressAvailable < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [String] address (mandatory) - address
    #
    # @return [WalletAddressesManagement::IsAddressAvailable]
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

        r = validate_and_sanitize
        return r unless r.success?

        r = is_address_available
        return r unless r.success?

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

      r = validate
      return r unless r.success?

      @address = sanitize_address(@address)

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
        @api_response_data['is_address_available'] = false
      else
        @api_response_data['is_address_available'] = true
      end

      success

    end
  end
end