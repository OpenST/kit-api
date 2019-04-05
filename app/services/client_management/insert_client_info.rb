module ClientManagement

  class InsertClientInfo < ServicesBase

    # Initialize
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By:
    #
    # @params [String] company_name (mandatory) -  company name
    # @params [Boolean] mobile_app_flag (mandatory)
    # @params [Boolean] 1m_users_flag (mandatory)
    #
    # @return
    #
    def initialize(params)
      super

      @company_name = @params[:company_name]
      @mobile_app_flag = @params[:mobile_app_flag]
      @one_m_users_flag = @params[:one_m_users_flag] #???
    end

    # Perform
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = insert_update_token_details
        return r unless r.success?

        r = delete_old_addresses
        return r unless r.success?

        r = create_api_credentials
        return r unless r.success?

        success_with_data({token: @token_details.formated_cache_data})

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Anagha
    # * Date: 05/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      @name = @name.to_s.strip
      @symbol = @symbol.to_s.strip.upcase

      validation_errors = validate_token_creation_params

      if validation_errors.present?
        return validation_error(
          'a_tm_itd_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end



  end

end