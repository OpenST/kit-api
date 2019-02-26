module TokenManagement

  class StartMint < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (mandatory) - logged in client manager object
    # @params [String] approve_transaction_hash (mandatory)
    # @params [String] request_stake_transaction_hash (mandatory)
    # @params [String] staker_address (mandatory)
    # @params [String] fe_ost_to_stake (mandatory)
    # @params [String] fe_bt_to_mint (mandatory)
    #
    #
    # @return [TokenManagement::StartMint]
    #
    def initialize(params)

      super

      @client_manager = params[:client_manager]
      @approve_tx_hash = params[:approve_transaction_hash]
      @request_stake_tx_hash = params[:request_stake_transaction_hash]
      @staker_address = params[:staker_address]
      @fe_ost_to_stake = params[:fe_ost_to_stake]
      @fe_bt_to_mint = params[:fe_bt_to_mint]

      @api_response_data = {}
      @token_id = nil
      @workflow_id = nil

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_and_validate_token
        return r unless r.success?

        r = add_token_to_response
        return r unless r.success?

        @token_id = @token[:id]

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_workflow_data
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    def validate_and_sanitize

      r = validate
      return r unless r.success?

      # Santize
      @approve_tx_hash = Util::CommonValidator.sanitize_transaction_hash(@approve_tx_hash)
      @request_stake_tx_hash = Util::CommonValidator.sanitize_transaction_hash(@request_stake_tx_hash)
      @staker_address = Util::CommonValidator.sanitize_ethereum_address(@staker_address)

      validation_errors = validate_input_params

      if validation_errors.present?
        return validation_error(
          'tm_sm_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      success
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
          's_tm_sm_1',
          'mint_not_allowed',
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Validate input params
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_input_params
      validation_errors = []

      unless Util::CommonValidator.is_transaction_hash?(@approve_tx_hash)
        validation_errors.push('invalid_approve_transaction_hash')
      end

      unless Util::CommonValidator.is_transaction_hash?(@request_stake_tx_hash)
        validation_errors.push('invalid_request_stake_transaction_hash')
      end

      unless Util::CommonValidator.is_ethereum_address?(@staker_address)
        validation_errors.push('invalid_staker_address')
      end

      validation_errors
    end

    # direct request to saas api
    #
    #
    # * Author: Ankit
    # * Date: 16/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def direct_request_to_saas_api
      params_for_saas_api = {
        approve_transaction_hash: @approve_tx_hash,
        request_stake_transaction_hash:@request_stake_tx_hash,
        staker_address: @staker_address,
        token_id: @token_id,
        client_id: @client_id,
        fe_ost_to_stake: @fe_ost_to_stake,
        fe_bt_to_mint: @fe_bt_to_mint
      }

      r = SaasApi::Token::StartMint.new.perform(params_for_saas_api)
      return r unless r.success?

      @workflow_id = r.data['workflow_id']

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
    def fetch_workflow_data

      cached_response_data = KitSaasSharedCacheManagement::WorkflowStatus.new([@workflow_id]).fetch
      @api_response_data[:workflow_current_step] = cached_response_data[@workflow_id][:current_step]

      @api_response_data[:workflow_extended] = {
        id: @workflow_id,
        kind: GlobalConstant::Workflow.bt_stake_and_mint,
        steps: cached_response_data[@workflow_id][:all_steps]
      }

      success

    end

  end

end