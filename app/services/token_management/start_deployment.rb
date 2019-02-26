module TokenManagement

  class StartDeployment < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (mandatory) - logged in client manager object
    #
    # @return [TokenManagement::StartDeployment]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]

      @api_response_data = {}
      @token_id = nil
      @workflow_id = nil

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

        r = validate
        return r unless r.success?

        r = fetch_and_validate_token
        return r unless r.success?

        r = add_token_to_response
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_workflow_current_status
        return r unless r.success?

        r = enqueue_job
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    # validate
    #
    # * Author: Kedar
    # * Date: 22/02/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def validate
      r = super
      return r unless r.success?

      r = ManagerManagement::SuperAdmin::CheckSuperAdminRole.new(
        {client_manager: @client_manager}).perform

      unless r.success?
        return error_with_data(
          's_tm_sd_1',
          'unauthorized_to_token_deploy',
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # validate token
    #
    # * Author: Puneet
    # * Date: 22/02/2019
    # * Reviewed By: Alpesh
    #
    # @return [Result::Base]
    #
    def fetch_and_validate_token

      r = super
      return r unless r.success?

      if @token[:name].blank? || @token[:symbol].blank? || @token[:conversion_factor].blank? || @token[:decimal].blank? || @token[:status] != GlobalConstant::ClientToken.not_deployed
        return error_with_data(
            's_tm_sd_2',
            'token_deploy_not_allowed',
            GlobalConstant::ErrorAction.default
        )
      end

      @token_id = @token[:id]

      addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([@token_id]).fetch

      owner_address = [addresses_data[@token_id][GlobalConstant::TokenAddresses.owner_address_kind]]

      if owner_address.blank?
        return error_with_data(
            's_tm_sd_3',
            'token_deploy_not_allowed',
            GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # Direct request to saas api
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def direct_request_to_saas_api
      params_for_saas_api = {
        token_id: @token_id,
        client_id: @client_id
      }

      saas_response = SaasApi::Token::Deploy.new.perform(params_for_saas_api)
      return saas_response unless saas_response.success?

      @workflow_id = saas_response.data['workflow_id']

      success
    end


    # Fetch workflow current status
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_workflow_current_status

      cached_response_data = KitSaasSharedCacheManagement::WorkflowStatus.new([@workflow_id]).fetch

      workflow_current_step = {}
      if cached_response_data[@workflow_id].present?
        workflow_current_step = cached_response_data[@workflow_id][:current_step]
      end
      @api_response_data['workflow_current_step'] = workflow_current_step
      @api_response_data['workflow'] = {
        id: @workflow_id,
        kind: GlobalConstant::Workflow.token_deploy
      }

      success
    end

    # Enqueue Job
    #
    # * Author: Ankit
    # * Date: 05/02/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def enqueue_job

      BackgroundJob.enqueue(
        CreateApiCredentialsJob,
        {
          client_id: @client_id
        }
      )

      success

    end

  end

end