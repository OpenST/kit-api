module DashboardManagement

  class Get < ServicesBase

    # Initialize
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::GetDeploymentDetail]
    #
    def initialize(params)
      super

      @client_id = @params[:client_id]

      @token_id = nil
    end

    # Perform
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_and_validate_token
        return r unless r.success?

        r = fetch_workflow
        return r unless r.success?

        r = fetch_goto
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        prepare_response
      end

    end

    # Find & validate client
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    # Sets @token
    #
    def fetch_and_validate_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tm_b')
      return error_with_go_to(
          token_resp.internal_id,
          token_resp.general_error_identifier,
          GlobalConstant::GoTo.token_setup
      ) unless token_resp.success?

      @token = token_resp.data

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
                                    from_page: GlobalConstant::GoTo.token_dashboard
                                  }).fetch_by_economy_state

    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 01/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_payloads
      r = SubEnvPayload.new({client_id:@client_id}).perform
      return r unless r.success?

      @sub_env_payloads = r.data[:sub_env_payloads]

      success
    end

    # direct request to saas api
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def direct_request_to_saas_api
      params_for_saas_api = {
        token_id: @token[:id],
        client_id: @client_id,
      }

      r = SaasApi::Dashboard::Get.new.perform(params_for_saas_api)
      return r unless r.success?

      @total_supply = r.data['totalSupply']
      @total_supply_dollar = r.data['totalSupplyDollar']
      @circulating_supply = r.data['circulatingSupply']
      @circulating_supply_dollar = r.data['circulatingSupplyDollar']
      @total_volume = r.data['totalVolume']
      @total_volume_dollar = r.data['totalVolumeDollar']

      success
    end

    # direct request to saas api
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def prepare_response
      success_with_data(
        {
          token: @token,
          dashboard_details: {
            total_supply: @total_supply,
            total_supply_dollar: @total_supply_dollar,
            circulating_supply: @circulating_supply,
            circulating_supply_dollar: @circulating_supply_dollar,
            total_volume: @total_volume,
            total_volume_dollar: @total_volume_dollar
          },
          sub_env_payloads: @sub_env_payloads
        }
      )
    end

  end

end
