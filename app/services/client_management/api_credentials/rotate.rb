module ClientManagement

  module ApiCredentials

    class Rotate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2018
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) -  client id
      # @params [Integer] buffer_time (optional) - in minutes time till which old keys could still be used
      #
      # @return [ClientManagement::ApiCredentials::Rotate]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]
        @buffer_time = @params[:buffer_time]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = handle_existing_keys
          return r unless r.success?

          r = create_new_keys
          return r unless r.success?

          ClientManagement::ApiCredentials::Fetch.new(client_id:@client_id).perform

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
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

      # Mark existing keys as to be expiring soon
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
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

        ApiCredential.where(id: existing_row.id).where('expiry_timestamp IS NULL').update_all(expiry_timestamp: current_timestamp + @buffer_time * 60)

        KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).clear([existing_row.api_key])

        success

      end

      # Create new keys
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def create_new_keys
        ::ApiCredentials::Create.new(client_id: @client_id).create_and_insert_new_keys
      end

    end

  end

end