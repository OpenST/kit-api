module WalletAddressesManagement
  class GetWalletAddresses < ServicesBase

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

      @api_response_data = {}
      @api_response_data[:meta] = {}
      @api_response_data[:meta][:nextPagePayload] = {}
      @api_response_data[:result_type] = 'token_details'

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

        fetch_token_details

        fetch_default_price_points

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

    # Fetch token details
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      @token_details = CacheManagement::TokenDetails.new([@client_id]).fetch
      @api_response_data[:token_details] = @token_details
    end


    # Fetch default price points
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points


    end

  end
end