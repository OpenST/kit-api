module TokenManagement
  class RequestWhitelist < TokenManagement::Base
    # Initialize
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::StartMint]
    #
    def initialize(params)

      super

      @client_id = params[:client_id]
      @sandbox_token_name = params[:sandbox_token_name] |= nil
      @sandbox_token_symbol = params[:sandbox_token_symbol] |= nil
      @manager_obj = params[:manager]

      @api_response_data = {}

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = send_whitelist_request
        return r unless r.success?

        r = fetch_sub_env_response_data
        return r unless r.success?

        @api_response_data = @sub_env_payload_data

        success_with_data(@api_response_data)

      end
    end

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize
      validate

      fail OstCustomError.new error_with_data(
                                'a_tm_rw_1',
                                'invalid_api_params',
                                GlobalConstant::ErrorAction.default
                              ) if GlobalConstant::Base.sandbox_sub_environment?

      @client = CacheManagement::Client.new([@client_id]).fetch[@client_id]

      fail OstCustomError.new error_with_data(
                                'a_tm_rw_2',
                                'client_not_found',
                                GlobalConstant::ErrorAction.default
                              ) if @client.blank?


      success
    end


    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def send_whitelist_request

      unless @client[:mainnet_statuses].include? GlobalConstant::Client.mainnet_whitelist_requested_status
        #request whitelisting
        send_email
        set_whitelisting_requested_flag
      end

      success
    end

    # Send email
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def send_email

      manager_email_id = @manager_obj[:email]

      template_vars =  {
        client_id: @client_id, # Email, Sandbox Token Name, Sandbox Symbol
        manager_email_id: manager_email_id,
        company_web_domain: GlobalConstant::CompanyWeb.domain
      }

      if @sandbox_token_name.present?
        template_vars[:sandbox_token_name] = @sandbox_token_name
      end

      if @sandbox_token_symbol.present?
        template_vars[:sandbox_token_symbol] = @sandbox_token_symbol
      end

      Email::HookCreator::SendTransactionalMail.new(
        email: GlobalConstant::Base.support_email,
        template_name: GlobalConstant::PepoCampaigns.mainnet_whitelisting_request_template,
        template_vars: template_vars).perform
    end

    # set whitelisting requested flag
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def set_whitelisting_requested_flag
      client_obj = Client.where({id: @client_id}).first

      client_obj.send("set_#{GlobalConstant::Client.mainnet_whitelist_requested_status}")
      client_obj.save!
    end

    # fetch the sub env response data entity
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_sub_env_response_data
      r = SubEnvPayload.new({client_id:@client_id}).perform
      return r unless r.success?

      @sub_env_payload_data = r.data

      success
    end
  end
end