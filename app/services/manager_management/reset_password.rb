module ManagerManagement

  class ResetPassword < ServicesBase

    # Initialize
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @params [String] r_t (mandatory) - token for reset
    # @params [String] password (mandatory) - this is the new password
    # @params [String] confirm_password (mandatory) - this is the confirm password
    #
    # @return [ManagerManagement::ResetPassword]
    #
    def initialize(params)
      super

      @r_t = @params[:r_t]
      @password = @params[:password]
      @confirm_password = @params[:confirm_password]

      @reset_token = nil
      @manager_validation_hash_id = nil
      @manager_validation_hash_obj = nil
      @manager = nil
      @login_salt_d = nil
      @new_e_password = nil
    end

    # Perform
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_user_validation_record

        validate_reset_token

        fetch_user

        decrypt_login_salt

        @new_e_password = Manager.get_encrypted_password(@password, @login_salt_d)

        validate_previous_password

        update_password

        update_user_validation_hashes_status

        clear_cache

        success

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @reset_token, @temporary_token_id
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validation_errors = []

      validation_errors << 'password_invalid' unless Util::CommonValidator.is_valid_password?(@password)
      validation_errors << 'confirm_password_invalid' if @confirm_password != @password

      validation_errors << 'invalid_r_t' if @r_t.blank?

      fail OstCustomError.new validation_error(
          'um_cp_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
      ) if validation_errors.present?

      # NOTE: To be on safe side, check for generic errors as well
      validate

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@r_t)
      fail OstCustomError.new r unless r.success?

      decripted_t = r.data[:plaintext]

      splited_reset_token = decripted_t.split(':')

      invalid_url_error('um_rp_3') if splited_reset_token.length != 2

      @reset_token = splited_reset_token[1].to_s

      @manager_validation_hash_id = splited_reset_token[0].to_i

      success
    end

    # Fetch Manager validation record from token
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @manager_validation_hash_obj
    #
    def fetch_user_validation_record
      if @manager_validation_hash_id > 0
        @manager_validation_hash_obj = ManagerValidationHash.where(id: @manager_validation_hash_id).first
      end
    end

    # Validate Manager Validation hash
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_reset_token

      invalid_url_error('um_rp_4') if @manager_validation_hash_obj.blank?

      invalid_url_error('um_rp_5') if @manager_validation_hash_obj.validation_hash != @reset_token

      invalid_url_error('um_rp_6') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      invalid_url_error('um_rp_7') if @manager_validation_hash_obj.is_expired?

      invalid_url_error('um_rp_8') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.reset_password_kind

      success

    end

    # Fetch user
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @manager
    #
    # @return [Result::Base]
    #
    def fetch_user

      @manager = Manager.where(id: @manager_validation_hash_obj.manager_id).first

      fail OstCustomError.new validation_error(
          'um_rp_9',
          'invalid_api_params',
          ['invalid_r_t'],
          GlobalConstant::ErrorAction.default
      ) if @manager.blank? || !@manager.is_eligible_for_reset_passowrd?

      success

    end

    # Decrypt login salt
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @login_salt_d
    #
    # @return [Result::Base]
    #
    def decrypt_login_salt
      r = Aws::Kms.new('login', 'user').decrypt(@manager.authentication_salt)
      fail OstCustomError.new r unless r.success?

      @login_salt_d = r.data[:plaintext]

      success
    end

    # Validate if new password is not equal to prev password
    #
    # * Author: Aman
    # * Date: 03/03/2018
    # * Reviewed By:
    #
    # Sets @new_e_password
    #
    def validate_previous_password

      fail OstCustomError.new validation_error(
          'um_cp_vpp_1',
          'invalid_api_params',
          ['password_same'],
          GlobalConstant::ErrorAction.default
      ) if @manager.password == @new_e_password

      success

    end

    # Update password
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    def update_password
      @manager.password = @new_e_password
      if GlobalConstant::Manager.auto_blocked_status == @manager.status
        # if we had blocked a user for more than a threshhold failed login attemps we set status to blocked
        # now we should reset it to active
        @manager.status = GlobalConstant::Manager.active_status
        @manager.failed_login_attempt_count = 0
      end
      @manager.save!
    end

    # Update Manager Validation hash used in resetting password and make all others inactive.
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    def update_user_validation_hashes_status

      @manager_validation_hash_obj.status = GlobalConstant::ManagerValidationHash.used_status
      @manager_validation_hash_obj.save!

      ManagerValidationHash.where(
          manager_id: @manager.id,
          kind: GlobalConstant::ManagerValidationHash.reset_password_kind,
          status: GlobalConstant::ManagerValidationHash.active_status
      ).update_all(
          status: GlobalConstant::ManagerValidationHash.inactive_status
      )
      success

    end

    # Clear cache
    #
    # * Author: Puneet
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def clear_cache
      CacheManagement::Manager.new([@manager.id]).clear
      CacheManagement::ManagerSecure.new([@manager.id]).clear
    end

    # Invalid Request Response
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def invalid_url_error(code)
      fail OstCustomError.new validation_error(
          code,
          'invalid_api_params',
          ['invalid_r_t'],
          GlobalConstant::ErrorAction.default
      )
    end

  end

end
