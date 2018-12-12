module ManagerManagement

  module SignUp

    class WithoutInvite < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [String] password (mandatory) - user password
      # @param [String] browser_user_agent (mandatory) - browser user agent
      # @param [String] email (mandatory) - the email of the user which is to be signed up
      #
      # @return [ManagerManagement::SignUp::WithoutInvite]
      #
      def initialize(params)

        super

        @email = @params[:email]

        @authentication_salt_hash = nil
        @authentication_salt_d = nil

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

          validate_and_sanitize

          create_manager

          create_client

          update_manager

          create_client_manager

          set_cookie_value

          enqueue_job

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

        validation_errors = []

        validation_errors.push('password_incorrect') unless Util::CommonValidator.is_valid_password?(@password)

        @email = @email.to_s.downcase.strip
        validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)
        validation_errors.push('email_not_allowed_for_dev_program') unless Util::CommonValidator.is_whitelisted_email?(@email)

        fail OstCustomError.new validation_error(
                                    'm_su_1',
                                    'invalid_api_params',
                                    validation_errors,
                                    GlobalConstant::ErrorAction.default
                                ) if validation_errors.present?

        # NOTE: To be on safe side, check for generic errors as well
        validate

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

          if @manager_obj.status != GlobalConstant::Manager.invited_status

            fail OstCustomError.new validation_error(
                                        'um_su_4',
                                        'invalid_api_params',
                                        ['already_registered_email'],
                                        GlobalConstant::ErrorAction.default
                                    )

          end

          decrypt_login_salt

        else

          generate_login_salt

          @manager_obj = Manager.new(
              email: @email,
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

        client.send("set_#{GlobalConstant::Client.sandbox_active_status}")
        client.send("set_#{GlobalConstant::Client.has_enforced_mfa_property}")
        client.save!

        @client_id = client.id

        @client = client.formated_cache_data

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
        @manager_obj.save

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
        r = Aws::Kms.new('login', 'user').generate_data_key
        fail OstCustomError.new r unless r.success?

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
        r = Aws::Kms.new('login','user').decrypt(@manager_obj.authentication_salt)
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

        @client_manager_obj.send("set_#{GlobalConstant::ClientManager.is_super_admin_privilage}")

        @client_manager_obj.save!

      end

      # Enqueue Job
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def enqueue_job

        BackgroundJob.enqueue(
            SignUpWithoutInviteJob,
            {
                manager_id: @manager_id
            }
        )

      end

    end

  end

end