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

    # Invalid Request Response
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def invalid_url_error(code)
      fail OstCustomError.new validation_error(
                                  code,
                                  'invalid_api_params',
                                  ['invalid_client_id'],
                                  GlobalConstant::ErrorAction.default
                              )
    end

    # Find & validate client
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    # Sets @token
    #
    def fetch_and_validate_token
      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tm_b')
      return token_resp unless token_resp.success?

      @token = token_resp.data

      success
    end

    # Fetch default price points
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_default_price_points
      @price_points = KitSaasSharedCacheManagement::OstPricePointsDefault.new.fetch

      @api_response_data[:price_points] = @price_points

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