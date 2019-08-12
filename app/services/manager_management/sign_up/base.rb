module ManagerManagement

  module SignUp

    class Base < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @params [String] password (mandatory) - user password
      # @params [String] confirm_password (mandatory) - user password
      # @params [String] browser_user_agent (mandatory) - browser user agent
      # @params [String] fingerprint (mandatory) - device fingerprint
      # @params [String] fingerprint_type (mandatory) - device fingerprint type (1/0)
      #
      # @return [ManagerManagement::SignUp::Base]
      #
      def initialize(params)

        super

        @password = @params[:password]
        @confirm_password = @params[:confirm_password]
        @browser_user_agent = @params[:browser_user_agent]
        @fingerprint = @params[:fingerprint]
        @fingerprint_type = ManagerDevice.fingerprint_types[@params[:fingerprint_type]]

        @client_id = nil
        @manager_id = nil
        @manager_obj = nil
        @client = nil
        @client_manager_obj = nil
        @cookie_value = nil
        @invite_token = nil
        @decrypted_invite_token = nil

      end

      private

      # Decode Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      # Sets @decrypted_invite_token
      #
      def decrypt_invite_token
        decryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
        r = decryptor_obj.decrypt(@invite_token, GlobalConstant::ManagerValidationHash::manager_invite_kind)
        return invalid_url_error('mm_su_b_11') unless r.success?
        @decrypted_invite_token = r.data[:plaintext]
        success
      end

      # Validate Invite Token
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      # Sets @manager_validation_hash
      #
      def validate_invite_token

        splited_reset_token = @decrypted_invite_token.split(ManagerValidationHash.token_delimitter)
        return invalid_url_error('mm_su_b_1') if splited_reset_token.length != 2

        validation_hash = splited_reset_token[1]
        manager_validation_hash_id = splited_reset_token[0]

        return invalid_url_error('mm_su_b_3') unless Util::CommonValidator.is_numeric?(manager_validation_hash_id)

        return invalid_url_error('mm_su_b_4') unless Util::CommonValidator.is_alphanumeric?(validation_hash)

        @manager_validation_hash = ManagerValidationHash.where(id: manager_validation_hash_id.to_i).first

        return invalid_url_error('mm_su_b_4') if @manager_validation_hash.blank?

        return invalid_url_error('mm_su_b_5') if @manager_validation_hash.validation_hash != validation_hash

        return invalid_url_error('mm_su_b_6') if @manager_validation_hash.status != GlobalConstant::ManagerValidationHash.active_status

        return invalid_url_error('mm_su_b_7') if @manager_validation_hash.is_expired?

        return invalid_url_error('mm_su_b_8') if @manager_validation_hash.kind != GlobalConstant::ManagerValidationHash.manager_invite_kind

        @client_id = @manager_validation_hash.client_id
        @manager_id = @manager_validation_hash.manager_id
        @inviter_manager_id = @manager_validation_hash.extra_data[:inviter_manager_id].to_i
        @is_super_admin = @manager_validation_hash.extra_data[:is_super_admin]

        success

      end

      # Invalid Request Response
      #
      # * Author: Puneet
      # * Date: 11/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def invalid_url_error(code)
        validation_error(
          code,
          'invalid_api_params',
          ['invalid_i_t'],
          GlobalConstant::ErrorAction.default
        )
      end

      # Find & validate invited manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_invited_manager

        @manager_obj = Manager.where(id: @manager_id).first

        return invalid_url_error('mm_su_b_9') if @manager_obj.blank?

        return invalid_url_error('mm_su_b_10') if @manager_obj.status != GlobalConstant::Manager.invited_status

        success

      end

      # fetch client
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By: Sunil
      #
      # Sets @client
      #
      # @return [Result::Base]
      #
      def fetch_client
        response = Util::EntityHelper.fetch_and_validate_client(@client_id, 'um_rp')
        return invalid_url_error(response.internal_id) unless response.success?

        @client = response.data
        success
      end

      # Find & validate inviter manager
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Set @inviter_manager
      #
      # @return [Result::Base]
      #
      def fetch_and_validate_inviter_manager

        response = Util::EntityHelper.fetch_and_validate_manager(@inviter_manager_id, 'um_rp')
        return invalid_url_error(response.internal_id) unless response.success?

        @inviter_manager = response.data

        client_manager = CacheManagement::ClientManager.new([@inviter_manager_id], {client_id: @client_id}).fetch[@inviter_manager_id]
        return invalid_url_error('mm_su_b_15') if client_manager[:privileges].exclude?(GlobalConstant::ClientManager.is_super_admin_privilege)

        success

      end

      # Create entry in manager device with active status
      #
      # * Author: Santhosh
      # * Date: 22/05/2019
      # * Reviewed By:
      #
      def create_authorized_device

        key = "#{@manager_obj.id}:#{@fingerprint}:#{@fingerprint_type}"

        unique_hash = LocalCipher.get_sha_hashed_text(key)
        expiration_timestamp = current_timestamp + GlobalConstant::ManagerDevice.device_expiration_time

        # marking the first device for the manager as authorized
        @manager_device = ManagerDevice.new( manager_id: @manager_obj.id,
                                             fingerprint: @fingerprint,
                                             fingerprint_type: @fingerprint_type,
                                             unique_hash: unique_hash,
                                             expiration_timestamp: expiration_timestamp,
                                             status: GlobalConstant::ManagerDevice.authorized
        )

        @manager_device.save!

        success
      end

      # Set cookie value
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # Sets @cookie_value
      #
      def set_cookie_value
        @cookie_value = Manager.get_cookie_value(
            manager_id: @manager_obj.id,
            current_client_id: @manager_obj.current_client_id,
            token_s: @manager_obj.password,
            browser_user_agent: @browser_user_agent,
            manager_device_id: @manager_device.id,
            fingerprint: @fingerprint,
            last_session_updated_at: @manager_obj.last_session_updated_at,
            auth_level: GlobalConstant::Cookie.password_auth_prefix
        )
        success
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
        GlobalConstant::GoTo.verify_email
      end

      # Enqueue Job
      #
      # * Author: Puneet
      # * Date: 08/12/2018
      # * Reviewed By: Kedar
      #
      # @return [Result::Base]
      #
      def enqueue_job
        BackgroundJob.enqueue(
            SignUpJob,
            {
                manager_id: @manager_obj.id,
                platform_marketing: @marketing_communication_flag,
                manager_first_name: @first_name,
                manager_last_name: @last_name,
                client_id: @client_id
            }
        )

        success
      end

      # insert UTM params
      #
      # * Author: Alpesh
      # * Date: 15/04/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def create_utm_info
        return success if @utm_params.blank? || @utm_params[:utm_source].blank?

        client_manager = CacheManagement::ClientManager.new([@manager_obj.id], {client_id: @client_id}).fetch[@manager_obj.id]

        UtmLogs.create(
          {
            client_manager_id: client_manager.id,
            utm_source: @utm_params[:utm_source],
            utm_type: @utm_params[:utm_type],
            utm_medium: @utm_params[:utm_medium],
            utm_term: @utm_params[:utm_term],
            utm_campaign: @utm_params[:utm_campaign],
            utm_content: @utm_params[:utm_content]
          }
        )
        success
      end

      # Sanitize marcomm flag
      #
      # * Author: Ankit
      # * Date: 25/03/2019
      # * Reviewed By: Kedar
      #
      # @return [Result::Base]
      #
      def sanitize_marcomm_flag
        # being linient on validation. If marcomm is not on, consider it off.
        if @marcomm && @marcomm.to_s.downcase == 'on'
          @marketing_communication_flag = GlobalConstant::PepoCampaigns.platform_marketing_value_true
        else
          @marketing_communication_flag = GlobalConstant::PepoCampaigns.platform_marketing_value_false
        end

        success
      end

    end

  end

end