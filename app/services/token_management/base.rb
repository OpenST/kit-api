module TokenManagement

  class Base < ServicesBase

    # Initialize
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::Base]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]

      @client = nil

    end

    private

    # Fetch token details and ubt address
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By: Sunil
    #
    # Sets @token
    #
    # @return [Result::Base]
    #
    def fetch_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tm_b_1')
      return error_with_go_to(
          token_resp.internal_id,
          token_resp.general_error_identifier,
          GlobalConstant::GoTo.token_setup
      ) unless token_resp.success?

      @token = token_resp.data

      success

    end

    # Fetch default price points
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def fetch_price_points

      return error_with_go_to(
         'tm_b_4',
         'aux_chain_id_not_found',
         GlobalConstant::GoTo.token_setup
      ) unless @token[:aux_chain_id].present?
      aux_chain_id = @token[:aux_chain_id]

      price_points = KitSaasSharedCacheManagement::OstPricePoints.new([aux_chain_id]).fetch
      @api_response_data[:price_points] = price_points[aux_chain_id]
      success

    end

    # Add token details to response.
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def add_token_to_response
      @api_response_data[:token] = @token
      @api_response_data[:stake_currencies] = {}
      if @token[:stake_currency_id].present?
        stake_currencies = Util::EntityHelper.fetch_stake_currency_details(@token[:stake_currency_id]).data
        @api_response_data[:stake_currencies] = stake_currencies
        @token[:stake_currency_symbols] = stake_currencies.keys
      end
      success
    end

  end

end