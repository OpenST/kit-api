module ClientManagement

  module WebhookSecrets

    class Fetch < ServicesBase

      # Initialize
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      #
      # @return [ClientManagement::ApiCredentials::Fetch]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]
      end

      # Perform
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_webhook_secret
          return r unless r.success?

          success_with_data(@webhook_secrets_data)

        end

      end

      # Validate and sanitize given parameters
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        success

      end

      # Fetch existing api credentials
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_webhook_secret

        webhook_secrets = KitSaasSharedCacheManagement::WebhookSecret.new([@client_id]).fetch[@client_id]
        if webhook_secrets.blank?
          return error_with_data(
                   's_cm_ws_f_1',
                   'something_went_wrong',
                   GlobalConstant::ErrorAction.default,
                   @client_id
          )
        end

        @webhook_secrets_data = webhook_secrets

        success
      end

    end

  end

end
