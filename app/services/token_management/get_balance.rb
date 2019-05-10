module TokenManagement

  class GetBalance < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 29/04/2019
    # * Reviewed By:
    #
    # @params [Integer] address (mandatory) - address
    # @params [Array] currencies(mandatory) - currencies
    #
    # @return [TokenManagement::GetBalance]
    #
    def initialize(params)

      super

      @address = @params[:address]
      @currencies = @params[:currencies]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 29/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = request_saas_to_get_balance
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    # request saas to get balance for given address
    #
    # * Author: Ankit
    # * Date: 29/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def request_saas_to_get_balance
      params_for_get_balance_api = {
        address: @address,
        currencies: @currencies
      }

      saas_response = SaasApi::Token::GetBalance.new.perform(params_for_get_balance_api)
      return saas_response unless saas_response.success?

      @api_response_data[:balance] = saas_response.data

      success
    end
  end

end