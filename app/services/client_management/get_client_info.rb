module ClientManagement

  class GetClientInfo < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 08/04/2019
    # * Reviewed By: Kedar
    #
    # @return [ClientManagement::GetClientInfo]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @manager = @params[:manager]
      @client = @params[:client]
      @client_manager = @params[:client_manager]
      @luse_cookie_value = @params[:luse_cookie_value]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 08/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        success_with_data(
          {
            manager: @manager,
            client: @client,
            client_manager: @client_manager,
            sub_env_payloads: @sub_env_payloads
          })

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 09/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def fetch_goto

      return success unless @client[:properties].include?(GlobalConstant::Client.has_company_info_property)

      #check the cookie value here and redirect accordingly
      if @luse_cookie_value == GlobalConstant::Cookie.mainnet_env
        #redirect to mainnet token dashboard
        goto_screen = GlobalConstant::GoTo.mainnet_token_dashboard
      else
        #redirect to testnet token dashboard
        goto_screen = GlobalConstant::GoTo.sandbox_token_dashboard
      end

      error_with_go_to(
        'a_s_cm_gci_1',
        'unauthorized_to_perform_action',
        goto_screen
      )

    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 08/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_payloads
      r = SubEnvPayload.new({client_id:@client_id}).perform
      return r unless r.success?

      @sub_env_payloads = r.data[:sub_env_payloads]

      success
    end
  end
end