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
      @graph_type = @params[:graph_type]
      @duration_type = @params[:duration_type]

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

        r = fetch_graph_data
        return r unless r.success?

        success_with_data(@response_data)
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
      return error_with_data(
          'a_s_dm_ggd_2',
          'graph_data_not_found',
          GlobalConstant::ErrorAction.default
      ) unless token_resp.success?

      @token = token_resp.data[:id]
      success
    end

    # Fetch graph data
    #
    # * Author: Ankit
    # * Date: 19/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_graph_data

      graph_data = GraphData.select(:data).where(token_id: @token, graph_type: @graph_type, duration_type: @duration_type).first
      return error_with_data(
               'a_s_dm_ggd_1',
               'graph_data_not_found',
               GlobalConstant::ErrorAction.default
      ) if graph_data.blank?

      @response_data = graph_data.data

      success
    end

  end

end
