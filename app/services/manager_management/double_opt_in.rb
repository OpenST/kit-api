module ManagerManagement

  class DoubleOptIn < ServicesBase

    # Initialize
    #
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @params [String] r_t (mandatory) - token for double opt in
    #
    # @return [ManagerManagement::DoubleOptIn]
    #
    def initialize(params)

      super

      @r_t = @params[:r_t]
      @manager_id = @params[:manager_id]

      @token = nil
      @manager_validation_hash_id = nil
      @manager_validation_hash_obj = nil
      @manager = nil

    end

    # Perform
    #
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_logged_in_manager

        return success if @manager.send("#{GlobalConstant::Manager.has_verified_email_property}?")

        fetch_manager_validation_record

        validate_double_opt_token

        update_user_validation_hashes_status

        create_update_contact_email_service_hook

        mark_user_verified

        success
        
      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # Sets @reset_token, @temporary_token_id
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      invalid_url_error('um_doi_1') if @r_t.blank?

      # NOTE: To be on safe side, check for generic errors as well
      validate

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@r_t)
      fail OstCustomError.new r unless r.success?

      decripted_t = r.data[:plaintext]

      splited_reset_token = decripted_t.split(':')

      invalid_url_error('um_doi_2') if splited_reset_token.length != 2

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
    # Sets @manager
    #
    def fetch_logged_in_manager

      @manager = Manager.where(id: @manager_id).first

      fail OstCustomError.new validation_error(
        'um_dop_3',
        'invalid_api_params',
        ['invalid_user_id'],
        GlobalConstant::ErrorAction.default
      ) if @manager.blank? || @manager[:status] != GlobalConstant::Manager.active_status

      success

    end

    # Fetch Manager validation record from token
    #
    # * Author: Pankaj
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
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_double_opt_token

      invalid_url_error('um_doi_3') if @manager_validation_hash_obj.blank?

      invalid_url_error('um_doi_4') if @manager_validation_hash_obj.validation_hash != @token

      invalid_url_error('um_doi_5') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      invalid_url_error('um_doi_6') if @manager_validation_hash_obj.is_expired?

      invalid_url_error('um_doi_7') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.double_optin_kind

      fail OstCustomError.new unauthorized_access_response('um_doi_8') if @manager_validation_hash_obj.manager_id != @manager_id

      success

    end

    # Create update contact email hook
    #
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def create_update_contact_email_service_hook
      Email::HookCreator::UpdateContact.new(
        email: @manager.email,
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
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def mark_user_verified
      @manager.send("set_#{GlobalConstant::Manager.has_verified_email_property}")
      @manager.save!
      clear_cache
    end

    # Update Manager Validation hash used for double opt in and make all others inactive.
    #
    # * Author: Pankaj
    # * Date: 16/01/2018
    # * Reviewed By:
    #
    def update_user_validation_hashes_status
      @manager_validation_hash_obj.status = GlobalConstant::ManagerValidationHash.used_status
      @manager_validation_hash_obj.save!

      ManagerValidationHash.where(
        user_id: @manager_id,
        kind: GlobalConstant::ManagerValidationHash.double_optin_kind,
        status: GlobalConstant::ManagerValidationHash.active_status
      ).update_all(
        status: GlobalConstant::ManagerValidationHash.inactive_status
      )
      success
    end

    # Invalid Manager access response
    #
    # * Author: Pankaj
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
    # * Author: Pankaj
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

    #
    # * Author: Puneet
    # * Date: 11/01/2018
    # * Reviewed By
    #
    # @return [Result::Base]
    #
    def clear_cache
      CacheManagement::Manager.new([@manager_id]).clear
    end

  end

end
