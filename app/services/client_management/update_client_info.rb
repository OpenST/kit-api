module ClientManagement

  class UpdateClientInfo < ServicesBase

    # Initialize
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By: Kedar
    #
    # @params [String] company_name (mandatory) -  company name
    # @params [Boolean] mobile_app_flag (mandatory)
    # @params [Boolean] one_m_users_flag (mandatory)
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return
    #
    def initialize(params)
      super

      @company_name = @params[:company_name]
      @mobile_app_flag = @params[:mobile_app_flag]
      @one_m_users_flag = @params[:one_m_users_flag]
      @client_id = @params[:client_id]
      @manager = @params[:manager]
    end

    # Perform
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = update_client_info
        return r unless r.success?

        r = add_to_jira
        return r unless r.success?

        success_with_data({}, fetch_go_to)

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      validation_errors = []

      @company_name = @company_name.to_s.strip

      validation_errors.push('invalid_company_name') unless Util::CommonValidator.is_company_name_valid?(@company_name)
      validation_errors.push('invalid_mobile_app_flag') unless Util::CommonValidator.is_boolean_string?(@mobile_app_flag)
      validation_errors.push('invalid_one_m_users_flag') unless Util::CommonValidator.is_boolean_string?(@one_m_users_flag)

      if validation_errors.present?
        return validation_error(
          'a_s_cm_ici_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # Update client info in clients table.
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def update_client_info

      client = Client.where(id: @client_id).first

      client.company_name = @company_name
      client.send("set_#{GlobalConstant::Client.has_mobile_app_property}") if(@mobile_app_flag.to_i == 1)
      client.send("set_#{GlobalConstant::Client.has_one_million_users_property}") if(@one_m_users_flag.to_i == 1)
      client.send("set_#{GlobalConstant::Client.has_company_info_property}")
      client.save!

      success

    end

    # Update client info in clients table.
    #
    # * Author: Anagha
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @return [Hash]

    def get_platform_registration
      platform_registration = {
        company_name: @company_name,
        first_name: @manager[:first_name],
        last_name: @manager[:last_name],
        email_address: @manager[:email]
      }

      platform_registration[:mobile_app_flag] = @mobile_app_flag ? 'YES' : 'NO'
      platform_registration[:one_m_users_flag] = @one_m_users_flag ? 'More than 1 Million users' : 'Less than 1 Million users'

      return platform_registration
    end


    def add_to_jira

      if(@one_m_users_flag.to_i == 1)

        issue_params = {
          project_name:'TP', #get_project_name
          issue_type: GlobalConstant::Jira.task_issue_type,
          priority:GlobalConstant::Jira.medium_priority_issue,
          summary: get_issue_summary,
          description: get_issue_description
        }

        Rails.logger.info("-------------issue_params  @issue_params----#{issue_params} --------")

        Jira::CreateIssue.new(issue_params).perform

      end

      success

    end

    def get_summary_template
      "Enterprise: %{company_name}"
    end

    def get_issue_summary
      get_summary_template % get_platform_registration
    end

    def get_description_template
      "Company name: %{company_name} \n
       Mobile app: %{mobile_app_flag} \n
       Users: %{one_m_users_flag} \n
       First name: %{first_name} \n
       Last name : %{last_name} \n
       Email Address: %{email_address}"
    end

    def get_issue_description
      get_description_template % get_platform_registration
    end

    # Get goto for next page
    #
    # * Author: Anagha
    # * Date: 08/04/2019
    # * Reviewed By: Kedar
    #
    # @return [Hash]
    #
    def fetch_go_to
      # Redirect to testnet token setup
      GlobalConstant::GoTo.sandbox_token_dashboard
    end

  end

end