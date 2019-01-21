module TokenManagement

  class StartMint < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @approve_tx_hash = params[:approve_transaction_hash]
      @request_stake_tx_hash = params[:request_stake_transaction_hash]

      @client_id = params[:client_id]

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

        r = fetch_token_details
        return r unless r.success?

        r = direct_request_to_saas_api
        return r unless r.success?

        r = fetch_workflow_data
        return r unless r.success?

        success_with_data(@api_response_data)

      end
    end

    def validate_and_sanitize
      validate

      #santize
      @approve_tx_hash = Util::CommonValidator.sanitize_transaction_hash(@approve_tx_hash)
      @request_stake_tx_hash = Util::CommonValidator.sanitize_transaction_hash(@request_stake_tx_hash)

      validation_errors = validate_transaction_hashes

      if validation_errors.present?
        return validation_error(
          'a_tm_m_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end

    # Validate transaction hashes
    #
    # * Author: Ankit
    # * Date: 18/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_transaction_hashes
      validation_errors = []

      unless Util::CommonValidator.is_transaction_hash?(@approve_tx_hash)
        validation_errors.push('invalid_approve_transaction_hash')
      end

      unless Util::CommonValidator.is_transaction_hash?(@request_stake_tx_hash)
        validation_errors.push('invalid_request_stake_transaction_hash')
      end

      validation_errors
    end

    # Fetch token details
    #
    # * Author: Ankit
    # * Date: 17/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_token_details
      r = CacheManagement::TokenDetails.new([@client_id]).fetch || {}
      return error_with_data('a_tm_m_2',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default
      ) unless r.present?

      @token_id = r[@client_id][:id]
      success
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
        token_id: @token_id,
        client_id: @client_id
      }

      r = SaasApi::Token::Mint.new.perform(params_for_saas_api)
      return r unless r.success?

      #r.data['workflow_id']
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

      cached_response_data = CacheManagement::WorkflowStatus.new([@workflow_id]).fetch
      @api_response_data[:workflow_current_step] = cached_response_data[@workflow_id][:current_step]

      @api_response_data[:workflow_extended] = {
        id: @workflow_id,
        kind: GlobalConstant::Workflow.stake_and_mint,
        steps: cached_response_data[@workflow_id][:all_steps]
      }

      success
    end


  end

end