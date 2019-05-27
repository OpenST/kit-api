module ManagerManagement

  class DeviceVerification < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 22/05/2019
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
      @d_t = @params[:d_t]
      @manager_id = @params[:manager_id]

      @device_verification_token = nil
      @manager_validation_hash_id = nil
      @manager_validation_hash_obj = nil
      @manager_obj = nil

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 22/05/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = fetch_logged_in_manager
        return r unless r.success?

        r = validate_and_sanitize
        return r unless r.success?
        
        r = fetch_manager_validation_record
        return r unless r.success?

        r = validate_device_verification_token
        return r unless r.success?

        r = update_manager_validation_hashes_status
        return r unless r.success?

        r = mark_manager_device_verified
        return r unless r.success?

        if is_logged_in_manager?
          success_with_data({}, fetch_go_to)
        else
          success_with_data({})
        end
        
      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    # Sets @device_verification_token, @temporary_token_id
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      return invalid_url_error('mm_dv_1') if @d_t.blank?

      return invalid_url_error('mm_dv_2') unless Util::CommonValidator.is_valid_token?(@d_t)

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@d_t, GlobalConstant::ManagerValidationHash::device_verification_kind)
      return r unless r.success?

      decrypted_t = r.data[:plaintext]

      splited_reset_token = decrypted_t.split(':')

      return invalid_url_error('mm_dv_3') if splited_reset_token.length != 2

      @device_verification_token = splited_reset_token[1].to_s

      @manager_validation_hash_id = splited_reset_token[0].to_i

      success

    end

    # Fetch logged in Manager
    #
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    # Sets @manager_obj
    #
    def fetch_logged_in_manager

      return success unless is_logged_in_manager?

      @manager_obj = Manager.where(id: @manager_id).first

      return validation_error(
        'mm_dv_4',
        'invalid_api_params',
        ['invalid_manager_id'],
        GlobalConstant::ErrorAction.default
      ) if @manager_obj.blank? || @manager_obj[:status] != GlobalConstant::Manager.active_status

      success

    end

    # Fetch Manager validation record
    #
    # * Author: Ankit
    # * Date: 22/05/2019
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
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_device_verification_token

      return invalid_url_error('mm_dv_5') if @manager_validation_hash_obj.blank?

      return invalid_url_error('mm_dv_6') if @manager_validation_hash_obj.validation_hash != @device_verification_token

      return invalid_url_error('mm_dv_7') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      return invalid_url_error('mm_dv_8') if @manager_validation_hash_obj.is_expired?

      return invalid_url_error('mm_dv_9') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.device_verification_kind

      if is_logged_in_manager?
        return unauthorized_access_response('mm_dv_10') if @manager_validation_hash_obj.manager_id != @manager_id
      else
        @manager_obj = Manager.where(id: @manager_validation_hash_obj.manager_id).first
        @manager_id = @manager_validation_hash_obj.manager_id
      end

      @manager_device_id = @manager_validation_hash_obj.extra_data[:manager_device_id]
      @manager_device_obj = ManagerDevice.where(id: @manager_device_id).first

      success

    end


    # Mark user as verified.
    #
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    def mark_manager_device_verified
      @manager_device_obj.status = GlobalConstant::ManagerDevice.authorized
      @manager_device_obj.expiration_timestamp = current_timestamp + 30.days.to_i
      @manager_device_obj.save!

      success
    end

    # Update Manager Validation hash used for device verification and make all others inactive for the same device id.
    #
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    def update_manager_validation_hashes_status
      @manager_validation_hash_obj.status = GlobalConstant::ManagerValidationHash.used_status
      @manager_validation_hash_obj.save!

      ManagerValidationHash.where(
        manager_id: @manager_id,
        kind: GlobalConstant::ManagerValidationHash.device_verification_kind,
        status: GlobalConstant::ManagerValidationHash.active_status
      ).find_in_batches(batch_size: 100) do |manager_validation_hashes|
      manager_validation_hashes_ids_to_deactivate = []
        manager_validation_hashes.each do |manager_validation_hash|
          if manager_validation_hash.extra_data[:manager_device_id] == @manager_device_id
            manager_validation_hashes_ids_to_deactivate.push(manager_validation_hash.id)
          end
        end
      ManagerValidationHash.where(id: manager_validation_hashes_ids_to_deactivate).update_all(status: GlobalConstant::ManagerValidationHash.inactive_status)
      end

      success
    end

    # Invalid Manager access response
    #
    # * Author: Ankit
    # * Date: 22/05/2019
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
    # * Author: Ankit
    # * Date: 22/05/2019
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
    # * Author: Ankit
    # * Date: 22/05/2019
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

    # Return boolean if the manager is logged in
    #
    # * Author: Ankit
    # * Date: 22/05/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def is_logged_in_manager?
      @is_logged_in_manager == 1
    end

  end

end
