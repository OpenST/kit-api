module TokenManagement

  class GetTokenDetails < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Object] client_manager(optional) - Client manager
    #
    # @return [TokenManagement::GetTokenDetails]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        fetch_token_details

        fetch_workflow

        r = fetch_goto
        return r unless r.success?

        # TODO: Open this functionality when economy setup is functional
        #r = fetch_token_details_from_saas
        #return r unless r.success?

        fetch_default_price_points

        append_logged_in_manager_details

        @api_response_data[:sign_messages] = {
          wallet_association: GlobalConstant::MessageToSign.wallet_association
        }

        success_with_data(@api_response_data)

      end

    end

    # Fetch token details
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      @token = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id] || {}

      @api_response_data[:token] = @token

      success
    end

    # Fetch workflow details
    #
    # * Author: Shlok
    # * Date: 21/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_workflow
      @deployment_workflow = Workflow.where({
                                   client_id: @client_id,
                                   kind: Workflow.kinds[GlobalConstant::Workflow.token_deploy]
                                 })
                    .order('id DESC')
                    .limit(1).first
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
                                    deployment_workflow: @deployment_workflow,
                                    from_page: GlobalConstant::GoTo.token_setup
                                  }).fetch_by_economy_state

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
          contract_address: '0x0x0x0x00x0x0x31280931hdfad32193as34as1dsad2',
          client_id: @client_id
      }
      saas_response = SaasApi::Token::FetchDetails.new.perform(params) # TODO: Pass params appropriately
      return saas_response unless saas_response.success?

      @api_response_data[:token].merge!(saas_response.data)
    end

  end

end