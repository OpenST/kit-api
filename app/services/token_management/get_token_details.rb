module TokenManagement

  class GetTokenDetails < ServicesBase

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
      @client_manager = params[:client_manager]

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

        r = fetch_token_details
        return r unless r.success?

        # TODO: Open this functionality when economy setup is functional
        #r = fetch_token_details_from_saas
        #return r unless r.success?

        r = fetch_default_price_points
        return r unless r.success?

        r = append_logged_in_manager_details
        return r unless r.success?

        success_with_data(@api_response_data)

      end

    end

    # Append logged in manager details
    #
    # * Author: Santhosh
    # * Date: 04/01/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def append_logged_in_manager_details
      return success unless @client_manager.present?

      @api_response_data[:client_manager] = @client_manager

      success
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
      r = CacheManagement::TokenDetails.new([@client_id]).fetch || {}
      @api_response_data[:token] = r[@client_id]
      success
    end

    # Fetch token details from Saas
    #
    #
    # * Author: Santhosh
    # * Date: 07/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details_from_saas
      params = {
          chain_id: 12345,
          contract_address: '0x0x0x0x00x0x0x31280931hdfad32193as34as1dsad2'
      }
      r = SaasApi::Token::FetchDetails.new.perform(params) # TODO: Pass params appropriately
      return r unless r.success?

      @api_response_data[:token].merge!(r.data)
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
      @api_response_data[:price_points] = CacheManagement::OstPricePointsDefault.new.fetch
      success
    end

  end

end