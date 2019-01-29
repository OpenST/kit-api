module ManagerManagement

  class Team < ServicesBase

    # Initialize
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Integer] page_no (optional) - Page no.
    #
    # @return [ManagerManagement::ListAdmins]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @manager = @params[:manager]
      @client = @params[:client]
      @client_manager = @params[:client_manager]

      @api_response_data = {}
      @token = nil

    end

    # Perform
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_and_validate_token

        r = fetch_goto
        return r unless r.success?

        success_with_data(
          {
            manager: @manager,
            client: @client,
            client_manager: @client_manager
          })

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validate

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

    # Fetch token details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_goto

      FetchGoToByEconomyState.new({
                                    token: @token,
                                    client_id: @client_id,
                                    from_page: GlobalConstant::GoTo.team
                                  }).fetch_by_economy_state

    end

  end

end