module DashboardManagement

  class GetGraphsData < ServicesBase

    # Initialize
    #
    # * Author: Dhananjay
    # * Date: 19/06/2019
    # * Reviewed By: Kedar
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Object] manager(mandatory) - manager
    # @params [String] graph_type (mandatory) - graph type
    # @params [String] duration_type(mandatory) - duration type
    #
    # @return [DashboardManagement::GetGraphsData]
    #
    def initialize(params)
      super

      @client_id = @params[:client_id]
      @manager = @params[:manager]
      @manager = @params[:graph_type]
      @manager = @params[:duration_type]

      @token = nil
    end

    # Perform
    #
    # * Author: Dhananjay
    # * Date: 19/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_token
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?

        prepare_response
      end

    end

    # Find & validate client
    #
    # * Author: Dhananjay
    # * Date: 19/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    # Sets @token
    #
    def fetch_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'dm_ggd_1')
      return error_with_go_to(
          token_resp.internal_id,
          token_resp.general_error_identifier,
          GlobalConstant::GoTo.token_setup
      ) unless token_resp.success?

      @token = token_resp.data
      success
    end

    # Fetch go to by economy state
    #
    # * Author: Dhananjay
    # * Date: 19/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def fetch_goto

      FetchGoToByEconomyState.new({
                                    token: @token,
                                    client_id: @client_id,
                                    from_page: GlobalConstant::GoTo.token_dashboard
                                  }).fetch_by_economy_state

    end

    # Prepare final response
    #
    # * Author: Dhananjay
    # * Date: 19/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def prepare_response

      success_with_data(
        {
          token: @token
        }
      )
    end

  end

end
