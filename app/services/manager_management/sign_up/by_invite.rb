module ManagerManagement

  module SignUp

    class ByInvite < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @params [String] i_t (mandatory) - token if this user is signing up from via a manager invite link
      # @params [String] password (mandatory) - user password
      # @params [String] confirm_password (mandatory) - user password
      # @params [String] browser_user_agent (mandatory) - browser user agent
      # @params [String] fingerprint (mandatory) - device fingerprint
      # @params [String] fingerprint_type (mandatory) - device fingerprint type (1/0)
      # @params [Hash] utm_params (optional) - UTM params if client joins using marketing link.
      #
      # @return [ManagerManagement::SignUp::ByInvite]
      #
      def initialize(params)

        super

        @invite_token = @params[:i_t]
        @marcomm = @params[:marcomm]
        @first_name = @params[:first_name]
        @last_name = @params[:last_name]
        @utm_params = @params[:utm_params]

        @decrypted_invite_token = nil
        @manager_validation_hash = nil
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

          # 1. decode i_t to determine email and client to which invite is for
          # 2. find manager & client record

          r = decrypt_invite_token
          return r unless r.success?

          r = validate_invite_token
          return r unless r.success?

          r = fetch_and_validate_invited_manager
          return r unless r.success?

          r = fetch_client
          return r unless r.success?

          r = fetch_and_validate_inviter_manager
          return r unless r.success?

          r = decrypt_login_salt
          return r unless r.success?

          r = update_manager
          return r unless r.success?

          r = update_client_manager
          return r unless r.success?

          r = update_invite_token
          return r unless r.success?

          r = create_update_contact_email_service_hook
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
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        validation_errors = []

        validation_errors.push('password_invalid') unless Util::CommonValidator.is_valid_password?(@password)
        validation_errors.push('confirm_password_invalid') if @confirm_password != @password

        @first_name = @first_name.to_s.strip
        validation_errors.push('invalid_first_name') unless Util::CommonValidator.is_valid_name?(@first_name)

        @last_name = @last_name.to_s.strip
        validation_errors.push('invalid_last_name') unless Util::CommonValidator.is_valid_name?(@last_name)

        validation_errors.push('invalid_fingerprint') unless @fingerprint.length == 32

        if @invite_token.blank?

          validation_errors.push('missing_i_t')

        else

          @invite_token = @invite_token.to_s.strip

          unless Util::CommonValidator.is_valid_token?(@invite_token)
            validation_errors.push('invalid_i_t')
          end

        end

        return validation_error(
                                    'mm_su_bi_2',
                                    'invalid_api_params',
                                    validation_errors,
                                    GlobalConstant::ErrorAction.default
                                ) if validation_errors.present?

        # NOTE: To be on safe side, check for generic errors as well

        r = sanitize_marcomm_flag
        return r unless r.success?

        success

      end

      # Decrypt login salt
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @login_salt_d
      #
      # @return [Result::Base]
      #
      def decrypt_login_salt

        r = Aws::Kms.new(GlobalConstant::Kms.login_purpose, GlobalConstant::Kms.user_role).decrypt(@manager_obj.authentication_salt)
        return r unless r.success?

        @login_salt_d = r.data[:plaintext]

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

        @manager_obj.first_name = @first_name
        @manager_obj.last_name = @last_name
        @manager_obj.password = Manager.get_encrypted_password(@password, @login_salt_d)
        @manager_obj.current_client_id = @client_id

        @manager_obj.status = GlobalConstant::Manager.active_status
        @manager_obj.last_session_updated_at = current_timestamp
        @manager_obj.save

        status_to_set = GlobalConstant::Manager.has_verified_email_property
        column_name, value = Manager.send("get_bit_details_for_#{status_to_set}")

        Manager.where(id: @manager_obj.id).update_all(["? = ? | ?", column_name, column_name, value])

        Manager.deliberate_cache_flush(@manager_obj.id)

        success

      end

      # Update Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_invite_token

        # Mark this invite token as used
        @manager_validation_hash.status = GlobalConstant::ManagerValidationHash.used_status
        @manager_validation_hash.save!

        # Mark any other active invite token (s) for this manager as inactive
        ManagerValidationHash.where(
            manager_id: @manager_id,
            kind: GlobalConstant::ManagerValidationHash.manager_invite_kind,
            status: GlobalConstant::ManagerValidationHash.active_status
        ).update_all(
            status: GlobalConstant::ManagerValidationHash.inactive_status
        )

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

      # Create client manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      #
      def update_client_manager

        # Decide invite privilege depending on the is_super_admin set in the manager validation hash.

        unset_properties_map = {}
        set_properties_map = {}

        if @is_super_admin == GlobalConstant::ClientManager.is_super_admin_privilege
          column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::ClientManager.is_super_admin_invited_privilege}")
          unset_properties_map[column_name] = value

          column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::ClientManager.is_super_admin_privilege}")
          set_properties_map[column_name] = value
        else
          column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::ClientManager.is_admin_invited_privilege}")
          unset_properties_map[column_name] = value

          column_name, value = Client.send("get_bit_details_for_#{GlobalConstant::ClientManager.is_admin_privilege}")
          set_properties_map[column_name] = value
        end

        update_strings = []

        set_properties_map.each do |column_name, value|
          update_strings.push("#{column_name} = #{column_name} | #{value}")
        end

        unset_properties_map.each do |column_name, value|
          update_strings.push("#{column_name} = #{column_name} ^ #{value}")
        end

        update_string = update_strings.join(',')

        ClientManager.where(
            client_id: @client_id,
            manager_id: @manager_obj.id
        ).update_all([update_string])

        ClientManager.deliberate_cache_flush(@client_id, @manager_obj.id)

        success
      end

      # Get goto for next page
      #
      # * Author: Shlok
      # * Date: 07/01/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def fetch_go_to
        if @client[:properties].include?(GlobalConstant::Client.has_enforced_mfa_property)
    
          GlobalConstant::GoTo.setup_mfa
  
        else

          GlobalConstant::GoTo.sandbox_token_dashboard

        end

      end

    end

  end

end