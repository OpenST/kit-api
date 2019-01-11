module TokenManagement

  class Deploy < ServicesBase

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
      @token_id = @params[:token_id]

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

        return success_with_data({
          token: {
            "name": "Pepo Coin",
            "symbol": "Pepo",
            "conversion_factor": "2.5",
            "status": ""
          },
          workflow: {
            "id": "123...",
            "kind": "token_deploy"
          },
          workflow_current_step: {
            "display_text": "",
            "percent_completion": 10,
            "status": 0,
            "name": "step_name"
          }
        })

      end
    end

  end

end