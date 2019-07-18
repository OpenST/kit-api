module ManagerManagement

  module SignUp

    class WithoutInvite < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @params [String] password (mandatory) - user password
      # @params [String] browser_user_agent (mandatory) - browser user agent
      # @params [String] email (mandatory) - the email of the user which is to be signed up
      # @params [String] agreed_terms_of_service (mandatory) - if terms of service was accepted
      # @params [String] fingerprint (mandatory) - device fingerprint
      # @params [String] fingerprint_type (mandatory) - device fingerprint type (1/0)
      # @params [Hash] utm_params (optional) - UTM params if client joins using marketing link.
      #
      # @return [ManagerManagement::SignUp::WithoutInvite]
      #
      def initialize(params)

        super

        @email = @params[:email]
        @agreed_terms_of_service = @params[:agreed_terms_of_service]
        @marcomm = @params[:marcomm]
        @first_name = @params[:first_name]
        @last_name = @params[:last_name]
        @utm_params = @params[:utm_params]

        @authentication_salt_hash = nil
        @authentication_salt_d = nil
        @marketing_communication_flag = nil

      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = create_manager
          return r unless r.success?

          r = create_client
          return r unless r.success?

          r = update_manager
          return r unless r.success?

          r = create_client_manager
          return r unless r.success?

          r = create_authorized_device
          return r unless r.success?

          r = set_cookie_value
          return r unless r.success?

          r = enqueue_job
          return r unless r.success?

          r = create_utm_info
          return r unless r.success?

          success_with_data(
              {cookie_value: @cookie_value},
              fetch_go_to
          )

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        # NOTE: To be on safe side, check for generic errors as well
        r = validate
        return r unless r.success?

        validation_errors = []

        validation_errors.push('password_invalid') unless Util::CommonValidator.is_valid_password?(@password)
        validation_errors.push('invalid_agreed_terms_of_service') if @agreed_terms_of_service.to_s.downcase != 'on'

        @email = @email.to_s.downcase.strip
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)

        @first_name = @first_name.to_s.strip
        validation_errors.push('invalid_first_name') unless Util::CommonValidator.is_valid_name?(@first_name)

        @last_name = @last_name.to_s.strip
        validation_errors.push('invalid_last_name') unless Util::CommonValidator.is_valid_name?(@last_name)

        validation_errors.push('invalid_fingerprint') unless @fingerprint.length == 32

        return validation_error(
          'mm_su_wi_1',
          'invalid_api_params',
           validation_errors,
           GlobalConstant::ErrorAction.default
        ) if validation_errors.present?

        r = sanitize_marcomm_flag
        return r unless r.success?

        success

      end

      # Find or create user
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def create_manager

        @manager_obj = Manager.where(email: @email).first

        if @manager_obj.present?

          if @manager_obj.status == GlobalConstant::Manager.invited_status

            return validation_error(
              'mm_su_wi_3',
              'invalid_api_params',
              ['already_associated_email'],
              GlobalConstant::ErrorAction.default
            )

          end

          return validation_error(
              'mm_su_wi_4',
              'invalid_api_params',
              ['already_registered_email'],
              GlobalConstant::ErrorAction.default
          )

        else

          r = generate_login_salt
          return r unless r.success?

          @manager_obj = Manager.new(
              email: @email,
              first_name: @first_name,
              last_name: @last_name,
              authentication_salt: @authentication_salt_hash[:ciphertext_blob]
          )

        end

        password_e = Manager.get_encrypted_password(@password, @authentication_salt_d)

        @manager_obj.password = password_e
        @manager_obj.last_session_updated_at = current_timestamp
        @manager_obj.status = GlobalConstant::Manager.active_status

        @manager_obj.save!

        success

      end

      # Create client
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @client_id
      #
      def create_client

        client = Client.new

        client.send("set_#{GlobalConstant::Client.sandbox_whitelisted_status}")
        client.send("unset_#{GlobalConstant::Client.mainnet_whitelisted_status}")
        client.save!

        @client_id = client.id

        @client = client.formatted_cache_data

        success
      end

      # modify invited manager object
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_manager

        @manager_obj.current_client_id = @client_id
        @manager_obj.save!

        success
      end

      # Generate login salt
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @authentication_salt_hash, @authentication_salt_d
      #
      # @return [Result::Base]
      #
      def generate_login_salt
        r = Aws::Kms.new(GlobalConstant::Kms.login_purpose, GlobalConstant::Kms.user_role).generate_data_key
        return r unless r.success?

        @authentication_salt_hash = r.data
        @authentication_salt_d = @authentication_salt_hash[:plaintext]

        success
      end

      # Decrypt login salt
      #
      # * Author: Puneet
      # * Date: 10/12/2018
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

      # Create client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @client_manager_obj
      #
      def create_client_manager

        @client_manager_obj = ClientManager.new(
            client_id: @client_id,
            manager_id: @manager_obj.id
        )

        @client_manager_obj.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilege}")

        @client_manager_obj.save!

        update_campaign_attributes({
                                       entity_id: @manager_obj.id,
                                       entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
                                       attributes: { GlobalConstant::PepoCampaigns.super_admin =>  GlobalConstant::PepoCampaigns.super_admin_value },
                                       settings: {}
                                   })

        update_mile_stone_attributes

        success

      end

    end

  end

end