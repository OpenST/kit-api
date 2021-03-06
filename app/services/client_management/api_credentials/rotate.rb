module ClientManagement

  module ApiCredentials

    class Rotate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2018
      # * Reviewed By: Sunil
      #
      # @params [Integer] client_id (mandatory) -  client id
      # @params [Integer] buffer_time (optional) - in minutes time till which old keys could still be used
      # @params [Hash] client_manager (mandatory) - logged in client manager object
      # @params [Hash] show_keys_enable_flag (mandatory) -
      # @params [Hash] email_already_sent_flag (mandatory) -
      #
      # @return [ClientManagement::ApiCredentials::Rotate]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]
        @client_manager = @params[:client_manager]
        @buffer_time = @params[:buffer_time]

        @show_keys_enable_flag = @params[:show_keys_enable_flag]
        @email_already_sent_flag = @params[:email_already_sent_flag]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = handle_existing_keys
          return r unless r.success?

          r = create_new_keys
          return r unless r.success?

          r = enqueue_job_to_update_in_mappy_server
          return r unless r.success?

          r = fetch_api_credentials_data
          return r unless r.success?

          success_with_data(
            {
              api_keys: @api_credentials_data,
              email_already_sent_flag: @email_already_sent_flag

            })

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        if @buffer_time.present?
          return validation_error(
              's_cm_ac_r_1',
              'invalid_api_params',
              ['invalid_buffer_time'],
              GlobalConstant::ErrorAction.default
          ) unless Util::CommonValidator.is_integer?(@buffer_time)
          @buffer_time = @buffer_time.to_i
        else
          @buffer_time = GlobalConstant::ApiCredentials.buffer_time_in_minutes # 1 day
        end

        success

      end

      # validate
      #
      # * Author: Kedar
      # * Date: 22/02/2019
      # * Reviewed By: Puneet
      #
      # @return [Result::Base]
      #
      def validate
        r = super
        return r unless r.success?

        r = ManagerManagement::Team::CheckSuperAdminRole.new(
          {client_manager: @client_manager}).perform

        unless r.success?
          return error_with_data(
            's_cm_ac_r_1',
            'unauthorized_to_perform_action',
            GlobalConstant::ErrorAction.default
          )
        end

        success
      end

      # Mark existing keys as to be expiring soon
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def handle_existing_keys

        existing_rows = ApiCredential.non_expired_for_client(@client_id).select('id, api_key')

        if existing_rows.length == 0
          return success
        elsif existing_rows.length > 1
          return error_with_data(
              's_cm_ac_r_5',
              'client_already_initiated_rotate',
              GlobalConstant::ErrorAction.default
          )
        end

        existing_row = existing_rows.first

        ApiCredential.where(id: existing_row.id).where('expiry_timestamp IS NULL').update_all(
            expiry_timestamp: current_timestamp + @buffer_time * 60,
            updated_at: current_time
        )

        KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).clear([existing_row.api_key])

        success

      end

      # Create new keys
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def create_new_keys
        ::ApiCredentials::Create.new(client_id: @client_id).create_and_insert_new_keys
      end

      # Enqueue Job to update the API keys in Mappy Server
      #
      # * Author: Puneet
      # * Date: 13/04/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def enqueue_job_to_update_in_mappy_server

        BackgroundJob.enqueue(
            SyncApiKeysInDemoMappyJob,
            {
              client_id: @client_id,
              show_keys_enable_flag: @show_keys_enable_flag,
              email_already_sent_flag: @email_already_sent_flag
            }
        )

        success

      end

      # Fetch api credentials data
      #
      # * Author: Dhananjay
      # * Date: 08/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_api_credentials_data

        #@api_credentials_data = ClientManagement::ApiCredentials::Fetch.new(client_id: @client_id).perform

        r = ClientManagement::ApiCredentials::Fetch.new(client_id: @client_id,
                                                        show_keys_enable_flag: @show_keys_enable_flag,
                                                        email_already_sent_flag: @email_already_sent_flag).perform
        return r unless r.success?

        @api_credentials_data = r.data[:api_keys]

        success
      end

    end

  end

end