module DeveloperManagement

  class SecureDataAccessVerification < ServicesBase

    # Initialize
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @params [Object] manager(mandatory) - manager
    # @params [Boolean] is_logged_in_manager (mandatory) - is logged in manager
    # @params [String] a_t (optional) - token for secure data access verification
    #
    # @return [DeveloperManagement::SecureDataAccessVerification]
    #
    def initialize(params)

      super

      @manager_id = @params[:manager_id]
      @is_logged_in_manager = @params[:is_logged_in_manager]

      @a_t = @params[:a_t]

      @manager_validation_hash_id = nil
      @manager_validation_hash_obj = nil
      @manager_obj = nil

    end

    # Perform
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = fetch_logged_in_manager
        return r unless r.success?

        if @a_t.blank?

          return success_with_data({manager: @manager_obj.formatted_cache_data}) if is_logged_in_manager?

          return success_with_data({}, fetch_go_to)
        end

        r = validate_and_sanitize
        return r unless r.success?
        
        r = fetch_manager_validation_record
        return r unless r.success?

        r = validate_sda_token
        return r unless r.success?

        r = update_manager_validation_hashes_status
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
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # Sets @manager_validation_hash_id, @c_at_timestamp, @sda_token
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      return invalid_url_error('dm_sdav_1') if @a_t.blank?

      return invalid_url_error('dm_sdav_2') unless Util::CommonValidator.is_valid_token?(@a_t)

      decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = decryptor_obj.decrypt(@a_t, GlobalConstant::ManagerValidationHash::secure_data_access_kind)
      return r unless r.success?

      decrypted_t = r.data[:plaintext]

      splited_reset_token = decrypted_t.split(':')

      return invalid_url_error('dm_sdav_3') if splited_reset_token.length != 3

      @manager_validation_hash_id = splited_reset_token[0].to_i

      @c_at_timestamp = splited_reset_token[1]

      @sda_token = splited_reset_token[2]

      success

    end

    # Fetch logged in Manager
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # Sets @manager_obj
    #
    def fetch_logged_in_manager

      return success unless is_logged_in_manager?

      @manager_obj = Manager.where(id: @manager_id).first

      return validation_error(
        'dm_sdav_4',
        'invalid_api_params',
        ['invalid_manager_id'],
        GlobalConstant::ErrorAction.default
      ) if @manager_obj.blank? || @manager_obj[:status] != GlobalConstant::Manager.active_status

      success

    end

    # Fetch Manager validation record
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # Sets @manager_validation_hash_obj
    #
    def fetch_manager_validation_record
      @manager_validation_hash_obj = ManagerValidationHash.where(id: @manager_validation_hash_id,
                                                                 status: GlobalConstant::ManagerValidationHash.active_status).first
       success
    end

    # Validate Manager Validation hash
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_sda_token

      return invalid_url_error('dm_sdav_5') if @manager_validation_hash_obj.blank?

      return invalid_url_error('dm_sdav_6') if @manager_validation_hash_obj.validation_hash != @sda_token

      return invalid_url_error('dm_sdav_7') if @manager_validation_hash_obj.status != GlobalConstant::ManagerValidationHash.active_status

      return invalid_url_error('dm_sdav_8') if @manager_validation_hash_obj.is_expired?

      return invalid_url_error('dm_sdav_9') if @manager_validation_hash_obj.kind != GlobalConstant::ManagerValidationHash.secure_data_access_kind

      if is_logged_in_manager?
        return unauthorized_access_response('dm_sdav_10') if @manager_validation_hash_obj.manager_id != @manager_id
      else
        @manager_obj = Manager.where(id: @manager_validation_hash_obj.manager_id).first
        @manager_id = @manager_validation_hash_obj.manager_id
      end

      success

    end

    # invalidate other validation hashes
    # Update Manager Validation hash used for sda verification and make all others inactive for the same device id.
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    def update_manager_validation_hashes_status
      @manager_validation_hash_obj.status = GlobalConstant::ManagerValidationHash.used_status
      @manager_validation_hash_obj.save!

      ManagerValidationHash.where(
        manager_id: @manager_id,
        kind: GlobalConstant::ManagerValidationHash.secure_data_access_kind,
        status: GlobalConstant::ManagerValidationHash.active_status
      ).find_in_batches(batch_size: 100) do |manager_validation_hashes|
      manager_validation_hashes_ids_to_deactivate = []
        manager_validation_hashes.each do |manager_validation_hash|
          manager_validation_hashes_ids_to_deactivate.push(manager_validation_hash.id)
        end
      ManagerValidationHash.where(id: manager_validation_hashes_ids_to_deactivate).update_all(status: GlobalConstant::ManagerValidationHash.inactive_status)
      end

      success
    end

    # Invalid Manager access response
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def unauthorized_access_response(err)
      validation_error(
        err,
        'invalid_api_params',
        ['invalid_a_t'],
        GlobalConstant::ErrorAction.default
      )
    end

    # Invalid Request Response
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def invalid_url_error(code)
      validation_error(
        code,
        'invalid_api_params',
        ['invalid_a_t'],
        GlobalConstant::ErrorAction.default
      )
    end

    # Get goto
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def fetch_go_to
      @go_to = GlobalConstant::GoTo.developer
    end

    # Return boolean if the manager is logged in
    #
    # * Author: Dhananjay
    # * Date: 31/05/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def is_logged_in_manager?
      @is_logged_in_manager == 1
    end

  end

end
