module TokenManagement

  class GrantEthOst < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 24/01/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [String] address (mandatory) - Address
    #
    # @return [TokenManagement::GrantEthOst]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @address = @params[:staker_address]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = check_environment_validation
        return r unless r.success?

        r = check_time_validation
        return r unless r.success?

        r = check_address_association_with_client
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        success_with_data(@api_response_data)

      end

    end

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      # sanitize
      @address = sanitize_address(@address)
      @client_id = @client_id.to_i

      unless Util::CommonValidator.is_ethereum_address?(@address)
        return validation_error(
          'a_s_tm_g_1',
          'invalid_api_params',
          ['invalid_staker_address'],
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end


    # check if the given api is not from production main environment
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return
    def check_environment_validation
      #check if env is non production
      if GlobalConstant::Base.main_sub_environment?
        return validation_error(
          'a_s_tm_g_2',
          'unauthorized_access_response',
          [],
          GlobalConstant::ErrorAction.default
        )
      end
      success
    end

    # check if the grant was given to address in past 24 hours
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return
    def check_time_validation
      workflows = CacheManagement::WorkflowByClient.new([@client_id]).fetch

      if workflows[@client_id].present?
        workflows[@client_id].each do |wf|
          if wf.kind == GlobalConstant::Workflow.grant_eth_ost && (wf.status == GlobalConstant::Workflow.completed || wf.status == GlobalConstant::Workflow.in_progress)
            last_updated_at_epoch = wf.updated_at.to_datetime.to_i

            #If the row is updated in last 24 hours then throw error
            if (current_timestamp - last_updated_at_epoch) < GlobalConstant::Base.grant_timeout
              return error_with_data(
                'a_s_tm_g_3',
                'grant_limit_reached',
                GlobalConstant::ErrorAction.default
              )
            end
          end
        end
      end

      success
    end

    # check if the given address is associated with client id which is provided
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return
    def check_address_association_with_client

      client_wallet_address = ClientWalletAddress.where('address = ?' , @address).first

      if client_wallet_address.present?
        if client_wallet_address.client_id != @client_id
          return validation_error(
            'a_s_tm_g_4',
            'invalid_api_params',
            ['invalid_client_id', 'invalid_staker_address'],
            GlobalConstant::ErrorAction.default
          )
        end
      else
        return validation_error(
          'a_s_tm_g_5',
          'invalid_api_params',
          ['invalid_staker_address'],
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end


    # directs request to grant eth and ost to saas api
    #
    # * Author: Ankit
    # * Date: 24/01/2019
    # * Reviewed By:
    #
    # @return
    def direct_request_to_saas_api
      #if success then render success response
      params_for_saas_api = {
        address: @address,
        client_id: @client_id
      }

      saas_response = SaasApi::Token::GrantEthOst.new.perform(params_for_saas_api)
      return saas_response unless saas_response.success?

      @api_response_data[:workflow] = {
        id: saas_response.data[:workflow_id],
        kind: GlobalConstant::Workflow.grant_eth_ost
      }

      success
    end

  end
end

