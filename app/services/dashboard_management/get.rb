module DashboardManagement

  class Get < ServicesBase

    # Initialize
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By: Kedar
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

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?
        
        r = generate_graph_urls
        return r unless r.success?

        prepare_response
      end

    end

    # Find & validate client
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    # Sets @token
    #
    def fetch_token

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tm_b')
      return error_with_go_to(
          token_resp.internal_id,
          token_resp.general_error_identifier,
          GlobalConstant::GoTo.token_setup
      ) unless token_resp.success?

      @token = token_resp.data

      success
    end

    # Fetch token details
    #
    # * Author: Alpesh
    # * Date: 21/01/2019
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

    # fetch the sub env response data entity
    #
    # * Author: Alpesh
    # * Date: 01/02/2019
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

    # direct request to saas api
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By: Kedar
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

    # Generate presigned s3 urls for graphs
    #
    # * Author: Dhananjay
    # * Date: 02/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def generate_graph_urls
      duration_types = [GlobalConstant::GraphConstants.duration_type_day,
                        GlobalConstant::GraphConstants.duration_type_week,
                        GlobalConstant::GraphConstants.duration_type_month,
                        GlobalConstant::GraphConstants.duration_type_year]
      
      s3_manager = Aws::S3Manager.new
      
      @graph_urls = {total_tx: {}, tx_by_name: {}, tx_by_type: {}}

      duration_types.each do |duration_type|
  
        file_name_for_total_transactions = "#{@token[:id]}/total-transactions-by-#{duration_type}.json"
        file_name_for_transactions_by_type = "#{@token[:id]}/transactions-by-type-by-#{duration_type}.json"
        file_name_for_transactions_by_name = "#{@token[:id]}/transactions-by-name-by-#{duration_type}.json"
  
        # generate presigned URL for total_transactions
        r = s3_manager.get_signed_url_for(
          GlobalConstant::S3.analytics_bucket,
          "#{GlobalConstant::S3.analytics_graphs_folder}/#{file_name_for_total_transactions}",
          {
            expires_in: 120.minutes.to_i
          }
        )
        unless r.success?
          Rails.logger.error('generate_pre_signed_url_error', r.to_json)
        end
        @graph_urls[:total_tx][duration_type] = (r.data || {})[:presigned_url].to_s
  
        # generate presigned URL for transactions_by_type
        r = s3_manager.get_signed_url_for(
          GlobalConstant::S3.analytics_bucket,
          "#{GlobalConstant::S3.analytics_graphs_folder}/#{file_name_for_transactions_by_type}",
          {
            expires_in: 120.minutes.to_i
          }
        )
        unless r.success?
          Rails.logger.error('generate_pre_signed_url_error', r.to_json)
        end
        @graph_urls[:tx_by_type][duration_type] = (r.data || {})[:presigned_url].to_s
  
        # generate presigned URL for transactions_by_name
        r = s3_manager.get_signed_url_for(
          GlobalConstant::S3.analytics_bucket,
          "#{GlobalConstant::S3.analytics_graphs_folder}/#{file_name_for_transactions_by_name}",
          {
            expires_in: 120.minutes.to_i
          }
        )
        unless r.success?
          Rails.logger.error('generate_pre_signed_url_error', r.to_json)
        end
        @graph_urls[:tx_by_name][duration_type] = (r.data || {})[:presigned_url].to_s
        
      end

      success
    end

    # direct request to saas api
    #
    # * Author: Alpesh
    # * Date: 6/03/2019
    # * Reviewed By: Kedar
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
          graph_urls: @graph_urls,
          sub_env_payloads: @sub_env_payloads
        }
      )
    end

  end

end
