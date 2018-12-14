module ManagerManagement

  class DoubleOptIn < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @params [String] r_t (mandatory) - token for double opt in
    # @params [Integer] manager_id (mandatory) - manager id
    # @params [Hash] client (mandatory) - client to which this manager is associated
    # @params [Boolean] is_multi_auth_cookie_valid (optional)
    #
    # @return [ManagerManagement::DoubleOptIn]
    #
    def initialize(params)

      super

      @r_t = @params[:r_t]
      @manager_id = @params[:manager_id]
      @client = @params[:client]
      @is_multi_auth_cookie_valid = @params[:is_multi_auth_cookie_valid]

      @token = nil
      @manager_validation_hash_id = nil
      @manager_validation_hash_obj = nil
      @manager_obj = nil

    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_logged_in_manager

        if @manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?")
          return success_with_data({}, fetch_go_to)
        elsif @r_t.blank?
          return success_with_data({manager: @manager_obj.formated_cache_data})
        end

        fetch_manager_validation_record

        validate_double_opt_token

        update_user_validation_hashes_status

        create_update_contact_email_service_hook

        mark_manager_verified

        success_with_data({}, fetch_go_to)
        
      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # Sets @reset_token, @temporary_token_id
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validate

      return if @r_t.blank?

      invalid_url_error('mm_doi_2') unless Util::CommonValidator.is_valid_token?(@r_t)

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@r_t)
      fail OstCustomError.new r unless r.success?

      decripted_t = r.data[:plaintext]

      splited_reset_token = decripted_t.split(':')

      invalid_url_error('mm_doi_3') if splited_reset_token.length != 2

      @token = splited_reset_token[1].to_s

      @manager_validation_hash_id = splited_reset_token[0].to_i

      @manager_id = @manager_id.to_i

      success

    end

    # Fetch logged in Manager
    #
    # * Author: Puneet
    # * Date: 16/02/2018
    # * Reviewed By:
    #
    # Sets @manager_obj
    #
    def fetch_logged_in_manager

      @manager_obj = Manager.where(id: @manager_id).first

      fail OstCustomError.new validation_error(
        'mm_doi_4',
        'invalid_api_params',
        ['invalid_user_id'],
        GlobalConstant::ErrorAction.default
      ) if @manager_obj.blank? || @manager_obj[:status] != GlobalConstant::Manager.active_status

      success

    end

    # Fetch Manager validation record from token
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # Sets @manager_validation_hash_obj
    #
    def fetch_manager_validation_record
      @manager_validation_hash_obj = ManagerValidationHash.where(id: @manager_validation_hash_id).first
    end

    # Validate Manager Validation hash
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_double_opt_token

      invalid_url_error('mm_doi_5') if @manager_validation_hash_obj.blank?

      invalid_url_error('mm_doi_6') if @manager_validation_hash_obj.validation_hash != @token

      invalid_url_error('mm_doi_7') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      invalid_url_error('mm_doi_8') if @manager_validation_hash_obj.is_expired?

      invalid_url_error('mm_doi_9') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.double_optin_kind

      fail OstCustomError.new unauthorized_access_response('mm_doi_10') if @manager_validation_hash_obj.manager_id != @manager_id

      success

    end

    # Create update contact email hook
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def create_update_contact_email_service_hook
      Email::HookCreator::UpdateContact.new(
        email: @manager_obj.email,
        custom_attributes: {
          GlobalConstant::PepoCampaigns.double_optin_done_attribute => GlobalConstant::PepoCampaigns.double_optin_done_value
        },
        user_settings: {
          GlobalConstant::PepoCampaigns.double_opt_in_status_user_setting => GlobalConstant::PepoCampaigns.verified_value
        }
      ).perform
    end

    # Mark user as verified.
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def mark_manager_verified
      @manager_obj.send("set_#{GlobalConstant::Manager.has_verified_email_property}")
      @manager_obj.save!
    end

    # Update Manager Validation hash used for double opt in and make all others inactive.
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def update_user_validation_hashes_status
      @manager_validation_hash_obj.status = GlobalConstant::ManagerValidationHash.used_status
      @manager_validation_hash_obj.save!

      ManagerValidationHash.where(
        manager_id: @manager_id,
        kind: GlobalConstant::ManagerValidationHash.double_optin_kind,
        status: GlobalConstant::ManagerValidationHash.active_status
      ).update_all(
        status: GlobalConstant::ManagerValidationHash.inactive_status
      )
      success
    end

    # Invalid Manager access response
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def unauthorized_access_response(err)
      validation_error(
        err,
        'invalid_api_params',
        ['invalid_r_t'],
        GlobalConstant::ErrorAction.default
      )
    end

    # Invalid Request Response
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def invalid_url_error(code)
      validation_error(
        code,
        'invalid_api_params',
        ['invalid_r_t'],
        GlobalConstant::ErrorAction.default
      )
    end

    # Get goto for next page
    #
    # * Author: Puneet
    # * Date: 08/12/2018
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def fetch_go_to
      FetchGoTo.new({
                        is_password_auth_cookie_valid: true,
                        is_multi_auth_cookie_valid: @is_multi_auth_cookie_valid,
                        client: @client,
                        manager: @manager_obj.formated_cache_data
                    }).fetch_by_manager_state
    end

  end

end
