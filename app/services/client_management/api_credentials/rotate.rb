module ClientManagement

  module ApiCredentials

    class Rotate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2018
      # * Reviewed By:
      #
      # @param [Integer] client_id (mandatory) -  client id
      # @param [Integer] buffer_time (mandatory) - in minutes time till which old keys could still be used
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
      # @param [Hash] client_id (mandatory) - client_id
      #
      def perform

        r = validate_and_sanitize
        return r unless r.success?

        r = handle_existing_keys
        return r unless r.success?

        ClientManagement::ApiCredentials::Create.new(client_id: @client_id).perform

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

        if @buffer_time.present?
          return validation_error(
              's_cm_ac_r_1',
              'invalid_api_params',
              ['invalid_buffer_time'],
              GlobalConstant::ErrorAction.default
          ) unless Util::CommonValidator.is_integer?(@buffer_time)
          @buffer_time = @buffer_time.to_i
        else
          @buffer_time = 24 * 60 # 1 day
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
              's_cm_ac_r_2',
              'client_already_initiated_rotate',
              GlobalConstant::ErrorAction.default
          )
        end

        existing_row = existing_rows.first

        ApiCredential.where(id: existing_row.id).update_all(expiry_timestamp: current_timestamp + @buffer_time * 60)

        KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).clear([existing_row.api_key])

        success

      end

    end

  end

end