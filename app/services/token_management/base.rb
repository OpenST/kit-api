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

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tm_b')
      return error_with_go_to(
          token_resp.internal_id,
          token_resp.general_error_identifier,
          GlobalConstant::GoTo.token_setup
      ) unless token_resp.success?

      @token = token_resp.data

      response = Util::EntityHelper.fetch_and_validate_ubt_address(@token.id, 'tm_gtdbs_1')
      @token[:ubt_address] = response.data[:ubt_address] if response.data[:ubt_address].present?
      
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

      token_id = @token[:id]

      aux_chain_resp = Util::EntityHelper.fetch_chain_id_for_token_id(token_id, 'tm_b')

      return error_with_go_to(
         aux_chain_resp.internal_id,
         aux_chain_resp.general_error_identifier,
         GlobalConstant::GoTo.token_setup
      ) unless aux_chain_resp.success?
      aux_chain_id = aux_chain_resp.data[:aux_chain_id]

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

      success
    end

  end

end