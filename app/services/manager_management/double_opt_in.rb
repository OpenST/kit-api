module ManagerManagement

  class DoubleOptIn < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @params [Hash] client (mandatory) - client to which this manager is associated
    # @params [Boolean] is_multi_auth_cookie_valid (optional)
    # @params [Boolean] is_password_auth_cookie_valid (optional)
    # @params [Boolean] is_logged_in_manager (optional) - is logged in manager
    # @params [Integer] manager_id (optional) - manager id
    # @params [String] r_t (optional) - token for double opt in
    #
    # @return [ManagerManagement::DoubleOptIn]
    #
    def initialize(params)

      super

      @client = @params[:client]
      @is_password_auth_cookie_valid = @params[:is_password_auth_cookie_valid]
      @is_multi_auth_cookie_valid = @params[:is_multi_auth_cookie_valid]
      @is_logged_in_manager = @params[:is_logged_in_manager]
      @r_t = @params[:r_t]
      @manager_id = @params[:manager_id]

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

        r = fetch_logged_in_manager
        return r unless r.success?

        if is_logged_in_manager
          if @manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?")
            return success_with_data({}, fetch_go_to)
          elsif @r_t.blank?
            return success_with_data({manager: @manager_obj.formatted_cache_data})
          end
        else
          return success_with_data({}, fetch_go_to) if @r_t.blank?
        end

        r = validate_and_sanitize
        return r unless r.success?
        
        r = fetch_manager_validation_record
        return r unless r.success?

        r = validate_double_opt_token
        return r unless r.success?

        r = update_user_validation_hashes_status
        return r unless r.success?

        r = create_update_contact_email_service_hook
        return r unless r.success?

        r = mark_manager_verified
        return r unless r.success?

        if is_logged_in_manager
          success_with_data({}, fetch_go_to)
        else
          success_with_data({})
        end
        
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

      r = validate
      return r unless r.success?

      return invalid_url_error('mm_doi_11') if @r_t.blank?

      return invalid_url_error('mm_doi_2') unless Util::CommonValidator.is_valid_token?(@r_t)

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@r_t, GlobalConstant::ManagerValidationHash::double_optin_kind)
      return r unless r.success?

      decrypted_t = r.data[:plaintext]

      splited_reset_token = decrypted_t.split(':')

      return invalid_url_error('mm_doi_3') if splited_reset_token.length != 2

      @token = splited_reset_token[1].to_s

      @manager_validation_hash_id = splited_reset_token[0].to_i

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

      return success unless is_logged_in_manager

      @manager_obj = Manager.where(id: @manager_id).first

      return validation_error(
        'mm_doi_4',
        'invalid_api_params',
        ['invalid_manager_id'],
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
      success
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

      return invalid_url_error('mm_doi_5') if @manager_validation_hash_obj.blank?

      return invalid_url_error('mm_doi_6') if @manager_validation_hash_obj.validation_hash != @token

      return invalid_url_error('mm_doi_7') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      return invalid_url_error('mm_doi_8') if @manager_validation_hash_obj.is_expired?

      return invalid_url_error('mm_doi_9') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.double_optin_kind

      if is_logged_in_manager
        return unauthorized_access_response('mm_doi_10') if @manager_validation_hash_obj.manager_id != @manager_id
      end

      @manager_obj = Manager.where(id: @manager_validation_hash_obj.manager_id).first
      @manager_id = @manager_validation_hash_obj.manager_id

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
          receiver_entity_id: @manager_id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
          custom_attributes: {
              GlobalConstant::PepoCampaigns.platform_double_optin_done_attribute => GlobalConstant::PepoCampaigns.platform_double_optin_done_value
          },
          user_settings: {
              GlobalConstant::PepoCampaigns.double_opt_in_status_user_setting => GlobalConstant::PepoCampaigns.verified_value
          }
      ).perform

      success
    end

    # Mark user as verified.
    #
    # * Author: Puneet
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def mark_manager_verified
      status_to_set = GlobalConstant::Manager.has_verified_email_property
      column_name, value = Manager.send("get_bit_details_for_#{status_to_set}")

      Manager.where(id: @manager_id).update_all(["? = ? | ?", column_name, column_name, value])

      Manager.deliberate_cache_flush(@manager_id)

      success
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
                        is_password_auth_cookie_valid: @is_password_auth_cookie_valid,
                        is_multi_auth_cookie_valid: @is_multi_auth_cookie_valid,
                        client: @client,
                        manager: @manager_obj.present? ? @manager_obj.formatted_cache_data : nil
                    }).fetch_by_manager_state
    end
    
    def is_logged_in_manager
      @is_logged_in_manager == 1
    end

  end

end
