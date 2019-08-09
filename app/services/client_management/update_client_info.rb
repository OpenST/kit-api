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

        r = enqueue_ticketing_job
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

      # Set company name and relevant properties atomically
      clubbed_properties = {}

      if(@mobile_app_flag.to_i == 1)
        column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::Client.has_mobile_app_property}")

        clubbed_properties[column_name] = 0 unless clubbed_properties[column_name].present?
        clubbed_properties[column_name] |= value
      end

      if(@one_m_users_flag.to_i == 1)
        column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::Client.has_one_million_users_property}")

        clubbed_properties[column_name] = 0 unless clubbed_properties[column_name].present?
        clubbed_properties[column_name] |= value
      end

      column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::Client.has_company_info_property}")

      clubbed_properties[column_name] = 0 unless clubbed_properties[column_name].present?
      clubbed_properties[column_name] |= value

      update_strings = ["company_name = '#{@company_name}'"]
      clubbed_properties.each do |column_name, value|
        update_strings.push("#{column_name} = #{value}") # only 1 column is being updated which is 0 initially
      end

      update_string = update_strings.join(',')

      Client.where(id: @client_id).update_all([update_string])

      Client.deliberate_cache_flush(@client_id)

      success

    end

    # Update client info in clients table.
    #
    # * Author: Anagha
    # * Date: 15/04/2019
    # * Reviewed By:
    #
    # @return [Hash]
    # 
    def get_platform_registration
      {
        company_name: @company_name,
        first_name: @manager[:first_name],
        last_name: @manager[:last_name],
        email_address: @manager[:email],
        mobile_app_flag: @mobile_app_flag,
        one_m_users_flag: @one_m_users_flag
      }
    end

    # Enqueue job to sidekiq.
    #
    # * Author: Anagha
    # * Date: 16/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    # 
    def enqueue_ticketing_job
      
      # Skip creating jira ticket and deal in pipe-drive for development env.
      if GlobalConstant::Base.environment_name == 'development'
        return success
      end
      
      BackgroundJob.enqueue(
        TicketingJob,
        get_platform_registration
      )

      success

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