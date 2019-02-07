module ClientManagement

  module ApiCredentials

    class Deactivate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      #
      # @return [ClientManagement::ApiCredentials::Deactivate]
      #
      def initialize(params)
        super
        @client_id = params[:client_id]

        @deactivated_api_key = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_id_to_delete
          return r unless r.success?

          r = deactivate
          return r unless r.success?

          return ClientManagement::ApiCredentials::Fetch.new(client_id:@client_id).perform

        end

      end

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

        success

      end

      # Fetch id to delete
      #
      # * Author: Puneet
      # * Date: 05/02/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_id_to_delete
        api_credentials = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]

        # only one key is present, we can not deactivate it
        return validation_error(
          's_cm_ac_d_2',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        ) if api_credentials.length <= 1

        api_credentials.each do |api_credentials_row|
          if api_credentials_row[:expiry_timestamp].present?
            @deactivated_api_key = api_credentials_row[:key]
          end
        end

        return validation_error(
          's_cm_ac_d_3',
          'invalid_api_params',
          ['invalid_client_id'],
          GlobalConstant::ErrorAction.default
        ) if @deactivated_api_key.blank?

        success
      end

      # Deactivate api credentials
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def deactivate

        ApiCredential.where(api_key: @deactivated_api_key).update_all(expiry_timestamp: current_timestamp)

        KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).clear([@deactivated_api_key])

        success

      end

    end

  end

end
