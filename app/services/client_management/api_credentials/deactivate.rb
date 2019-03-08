module ClientManagement

  module ApiCredentials

    class Deactivate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      # @params [Hash] client_manager (mandatory) - logged in client manager object
      #
      # @return [ClientManagement::ApiCredentials::Deactivate]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]
        @client_manager = @params[:client_manager]

        @deactivated_api_key = nil
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

          r = fetch_id_to_deactivate
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
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

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
            's_cm_ac_d_1',
            'unauthorized_to_perform_action',
            GlobalConstant::ErrorAction.default
          )
        end

        success
      end

      # Fetch id to deactivate
      #
      # * Author: Puneet
      # * Date: 05/02/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_id_to_deactivate
        api_credentials = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]

        # only one key is present, we can not deactivate it
        return validation_error(
          's_cm_ac_d_2',
          'invalid_api_params',
          ['cannot_deactivate_all_keys'],
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
          ['cannot_deactivate_all_keys'],
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

        ApiCredential.where(api_key: @deactivated_api_key).update_all(
            expiry_timestamp: current_timestamp,
            updated_at: current_time
        )

        KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).clear([@deactivated_api_key])

        success

      end

    end

  end

end
