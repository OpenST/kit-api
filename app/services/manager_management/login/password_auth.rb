module ManagerManagement

  module Login

    class PasswordAuth < ServicesBase
      
      # Initialize
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @params [String] email (mandatory) - the email of the user which is to be signed up
      # @params [String] password (mandatory) - user password
      # @params [String] browser_user_agent (mandatory) - browser user agent
      # @params [String] fingerprint (mandatory) - device fingerprint
      # @params [String] fingerprint_type (mandatory) - device fingerprint type (1/0)
      #
      # @return [ManagerManagement::Login::PasswordAuth]
      #
      def initialize(params)
        super

        @email = @params[:email]
        @password = @params[:password]
        @browser_user_agent = @params[:browser_user_agent]
        @fingerprint = @params[:fingerprint]
        @fingerprint_type = ManagerDevice.fingerprint_types[@params[:fingerprint_type]]

        @client = nil
        @client_manager = nil
        @manager_obj = nil
        @authentication_salt_d = nil
        @manager_device_id = nil
        @is_enqueue_job_needed = false
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_manager
          return r unless r.success?

          r = fetch_client
          return r unless r.success?

          r = fetch_client_manager
          return r unless r.success?

          r = decrypt_login_salt
          return r unless r.success?

          r = validate_password
          return r unless r.success?

          r = update_manager
          return r unless r.success?

          r = validate_device_fingerprint
          return r unless r.success?

          r = enqueue_job
          return r unless r.success?

          set_cookie_value
          
        end

      end

      private

      # Validate
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        validation_errors = []

        @email = @email.to_s.downcase.strip
        validation_errors.push('min_character_length_password_invalid') unless Util::CommonValidator.is_valid_min_length_of_password?(@password)
        validation_errors.push('max_character_length_password_invalid') unless Util::CommonValidator.is_valid_max_length_of_password?(@password)
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)

        validation_errors.push('invalid_fingerprint') unless @fingerprint.length == 32

        return validation_error(
          'm_l_pa_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        ) if validation_errors.present?

        # NOTE: To be on safe side, check for generic errors as well

        success

      end

      # Fetch user
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @manager_obj
      #
      # @return [Result::Base]
      #
      def fetch_manager

        @manager_obj = Manager.where(email: @email).first

        return validation_error(
            'm_l_pa_3',
            'invalid_api_params',
            ['email_not_registered'],
            GlobalConstant::ErrorAction.default
        ) if !@manager_obj.present? || !@manager_obj.password.present? || !@manager_obj.authentication_salt.present?

        return validation_error(
            'm_l_pa_4',
            'invalid_api_params',
            ['email_auto_blocked'],
            GlobalConstant::ErrorAction.default
        ) if @manager_obj.status == GlobalConstant::Manager.auto_blocked_status

        return validation_error(
            'm_l_pa_5',
            'invalid_api_params',
            ['email_inactive'],
            GlobalConstant::ErrorAction.default
        ) if (@manager_obj.status != GlobalConstant::Manager.active_status)

        @mfa_enabled = @manager_obj.formatted_cache_data[:properties].include?(GlobalConstant::Manager.has_setup_mfa_property)

        success

      end

      # Fetch client
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @client
      #
      # @return [Result::Base]
      #
      def fetch_client
        response = Util::EntityHelper.fetch_and_validate_client(@manager_obj.current_client_id, 'mm_l_pa')
        return validation_error(
            'm_l_pa_6',
            'invalid_api_params',
            ['email_not_associated_with_client'],
            GlobalConstant::ErrorAction.default
        ) unless response.success?

        @client = response.data
        success
      end

      # Fetch client manager
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @client_manager
      #
      # @return [Result::Base]
      #
      def fetch_client_manager

        @client_manager = CacheManagement::ClientManager.new([@manager_obj.id],
       {client_id: @manager_obj.current_client_id}).fetch[@manager_obj.id]

        return validation_error(
            'm_l_pa_7',
            'invalid_api_params',
            ['email_not_associated_with_client'],
            GlobalConstant::ErrorAction.default
        ) if @client_manager.blank?

        privileges = @client_manager[:privileges]

        is_client_manager_active = Util::CommonValidator.is_active_admin?(privileges)

        return validation_error(
            'm_l_pa_8',
            'invalid_api_params',
            ['email_not_associated_with_client'],
            GlobalConstant::ErrorAction.default
        ) unless is_client_manager_active

        success

      end

      # Decrypt login salt
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # Sets @authentication_salt_d
      #
      # @return [Result::Base]
      #
      def decrypt_login_salt
        r = Aws::Kms.new(GlobalConstant::Kms.login_purpose, GlobalConstant::Kms.user_role).decrypt(@manager_obj.authentication_salt)
        return r unless r.success?

        @authentication_salt_d = r.data[:plaintext]

        success
      end

      # Validate password
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_password

        evaluated_password_e = Manager.get_encrypted_password(@password, @authentication_salt_d)

        unless evaluated_password_e == @manager_obj.password
          manager = Manager.where(id: @manager_obj.id).first # we might have stale data as KMS lookup might take time or ?
          manager.failed_login_attempt_count ||= 0
          manager.failed_login_attempt_count = manager.failed_login_attempt_count + 1
          manager.status = GlobalConstant::Manager.auto_blocked_status if manager.failed_login_attempt_count >= 5
          manager.save
          return validation_error(
              'mm_l_pa_9',
              'invalid_api_params',
              ['password_incorrect'],
              GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Update last_session_updated_at
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager_obj.failed_login_attempt_count = 0
        @manager_obj.last_session_updated_at = current_timestamp
        @manager_obj.save!

        success

      end

      # Validate device fingerprint
      #
      # * Author: Santhosh
      # * Date: 23/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_device_fingerprint

        key = "#{@manager_obj.id}:#{@fingerprint}:#{@fingerprint_type}"
        unique_hash = LocalCipher.get_sha_hashed_text(key)
        future_timestamp = current_timestamp + GlobalConstant::ManagerDevice.device_expiration_time

        device_db_obj = nil

        device_cache_obj = CacheManagement::ManagerDeviceByUniqueHash.new([unique_hash]).fetch[unique_hash]
        is_new_device = !device_cache_obj.present?

        if is_new_device
          # Insert into manager_devices for new device
          device_db_obj = ManagerDevice.new(manager_id: @manager_obj.id,
                                              fingerprint: @fingerprint,
                                              fingerprint_type: @fingerprint_type,
                                              unique_hash: unique_hash,
                                              expiration_timestamp: future_timestamp,
                                              status: GlobalConstant::ManagerDevice.un_authorized)

          device_db_obj.save!

          @is_enqueue_job_needed = true
        else
          is_device_expired = (device_cache_obj[:expiration_timestamp].to_i - current_timestamp) <= 0
          is_device_not_authorized = device_cache_obj[:status] == GlobalConstant::ManagerDevice.un_authorized

          # update the manager device using id for expiration_timestamp and status (if needed)
          update_params = {
            expiration_timestamp: future_timestamp
          }

          if is_device_expired
            update_params[:status] = GlobalConstant::ManagerDevice.un_authorized
          end

          if is_device_expired || is_device_not_authorized
            @is_enqueue_job_needed = true
          end

          ManagerDevice.where(id: device_cache_obj[:id]).update_all(update_params)
          CacheManagement::ManagerDeviceByUniqueHash.new([device_cache_obj[:unique_hash]]).clear
          CacheManagement::ManagerDeviceById.new([device_cache_obj[:id]]).clear
        end

        @manager_device_id = device_cache_obj[:id] || device_db_obj[:id]

        success
      end

      # Enqueue job
      #
      # * Author: Ankit
      # * Date: 31/05/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def enqueue_job
        return success unless @is_enqueue_job_needed

        BackgroundJob.enqueue(
          DeviceRegistrationJob,
          {
            manager_id: @manager_obj.id,
            manager_device_id: @manager_device_id
          }
        ) unless @mfa_enabled

        success
      end

      # Set cookie value
      #
      # * Author: Puneet
      # * Date: 15/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_cookie_value

        cookie_value = Manager.get_cookie_value(
            manager_id: @manager_obj.id,
            current_client_id: @manager_obj.current_client_id,
            token_s: @manager_obj.password,
            browser_user_agent: @browser_user_agent,
            manager_device_id: @manager_device_id,
            fingerprint: @fingerprint,
            last_session_updated_at: @manager_obj.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )

        success_with_data({cookie_value: cookie_value}, fetch_go_to)

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

        return GlobalConstant::GoTo.verify_device if @is_enqueue_job_needed && !@mfa_enabled

        FetchGoTo.new({
                        is_password_auth_cookie_valid: true,
                        is_multi_auth_cookie_valid: false,
                        client: @client,
                        manager: @manager_obj.formatted_cache_data
                      }).fetch_by_manager_state


      end

    end

  end

end