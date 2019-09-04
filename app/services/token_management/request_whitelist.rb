module TokenManagement
  class RequestWhitelist < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 30/01/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client (mandatory) - Client
    # @params [Hash] client_manager (mandatory) - logged in client manager object
    # @params [Hash] manager (mandatory) - manager
    # @params [String] sandbox_token_name (optional) - Sandbox token name
    # @params [String] sandbox_token_symbol (optional) - Sandbox token symbol
    #
    # @return [TokenManagement::RequestWhitelist]
    #
    def initialize(params)
      super

      @client = @params[:client]
      @client_manager = @params[:client_manager]
      @manager = @params[:manager]
      @sandbox_token_name = @params[:sandbox_token_name]
      @sandbox_token_symbol = @params[:sandbox_token_symbol]

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
      r = validate
      return r unless r.success?

      return error_with_data(
        's_tm_rw_1',
        'invalid_api_params',
        GlobalConstant::ErrorAction.default
      ) if GlobalConstant::Base.sandbox_sub_environment?

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

      r = ManagerManagement::Team::CheckSuperAdminRole.new(
        {client_manager: @client_manager}).perform

      unless r.success?
        return error_with_data(
          's_tm_rw_3',
          'unauthorized_to_perform_action',
          GlobalConstant::ErrorAction.default
        )
      end

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

        r = set_whitelisting_requested_flag
        return r unless r.success?

        r = create_issue_in_jira
        return r unless r.success?
      end

      success
    end

    # Create ticket in jira for enterprise company/organization
    #
    # * Author: Anagha
    # * Date: 17/04/2019
    # * Reviewed By:
    #
    def create_issue_in_jira

      issue_params = {
        project_name:GlobalConstant::Jira.cs_operation_project_name,
        issue_type: GlobalConstant::Jira.task_issue_type,
        priority:GlobalConstant::Jira.medium_priority_issue,
        assignee: GlobalConstant::Jira.move_to_prod_assignee_name,
        summary: "User requested whitelisting",
        description: get_issue_description
      }

      r = Ticketing::Jira::Issue.new(issue_params).perform
      return r unless r.success?

      success

    end

    # Get description for jira ticket
    #
    # * Author: Anagha
    # * Date: 17/04/2019
    # * Reviewed By:
    #
    # @returns [String]
    #
    def get_issue_description
      get_description_template % get_platform_registration
    end

    # Get platform registration fields
    #
    # * Author: Anagha
    # * Date: 17/04/2019
    # * Reviewed By:
    #
    # @returns [Hash]
    #
    def get_platform_registration
      {
        company_name: @client[:company_name],
        full_name: @manager[:first_name] + " " + @manager[:last_name],
        email_address: @manager[:email],
      }
    end

    # Get description template for jira ticket
    #
    # * Author: Anagha
    # * Date: 17/04/2019
    # * Reviewed By:
    #
    # @returns [String]
    #
    def get_description_template
      "Company name: %{company_name}
       Full name: %{full_name}
       Email Address: [%{email_address}|mailto:%{email_address}]"
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

      set_props_arr = [GlobalConstant::Client.mainnet_whitelist_requested_status]

      Client.atomic_update_bitwise_columns(@client[:id], set_props_arr, [])

      success
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
      r = SubEnvPayload.new({client_id:@client[:id]}).perform
      return r unless r.success?

      @sub_env_payload_data = r.data

      success
    end
  end
end
