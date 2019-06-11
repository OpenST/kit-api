module ClientManagement

  module WebhookSecrets

    class Rotate < ServicesBase

      # Initialize
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      #
      # @return [ClientManagement::WebhookSecrets::Rotate]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]

        @show_keys_enable_flag = @params[:show_keys_enable_flag]
        @email_already_sent_flag = @params[:email_already_sent_flag]
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

          if @show_keys_enable_flag == 1 && @email_already_sent_flag == 1

            r = saas_call_to_rotate_secret
            return r unless r.success?

            r = fetch_webhook_secret
            return r unless r.success?

          else

            return error_with_data(
              's_cm_ws_r_2',
              'unauthorized_access_response',
              GlobalConstant::ErrorAction.default,
              @client_id
            )

          end

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

      # Call saas to rotate client webhook secret.
      #
      # * Author: Alpesh
      # * Date: 07/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def saas_call_to_rotate_secret
        #if success then render success response
        params_for_saas_api = {
          client_id: @client_id
        }

        saas_response = SaasApi::Client::RotateWebhookSecret.new.perform(params_for_saas_api)
        return saas_response unless saas_response.success?

        KitSaasSharedCacheManagement::WebhookSecret.new([@client_id]).clear

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
                   's_cm_ws_r_1',
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
