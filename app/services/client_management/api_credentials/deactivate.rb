module ClientManagement

  module ApiCredentials

    class Deactivate < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @param [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      # @param [Integer] id_to_deactivate (mandatory) - id of the row which needs to be deactivated
      #
      # @return [ClientManagement::ApiCredentials::Deactivate]
      #
      def initialize(params)
        super
        @client_id = params[:client_id]
        @id_to_deactivate = params[:id_to_deactivate]
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

        r = validate_and_sanitize
        return r unless r.success?

        r = deactivate
        return r unless r.success?

        success

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

        return validation_error(
            's_cm_ac_d_1',
            'invalid_api_params',
            ['invalid_id_to_deactivate'],
            GlobalConstant::ErrorAction.default
        ) unless Util::CommonValidator.is_integer?(@id_to_deactivate)

        @id_to_deactivate = @id_to_deactivate.to_i

        api_credentials = CacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]

        # only one key is present, we can not deactivate it
        return validation_error(
            's_cm_ac_d_2',
            'invalid_api_params',
            ['invalid_id_to_deactivate'],
            GlobalConstant::ErrorAction.default
        ) if api_credentials.length == 1

        # we can deactivate only the older api key
        return validation_error(
            's_cm_ac_d_3',
            'invalid_api_params',
            ['invalid_id_to_deactivate'],
            GlobalConstant::ErrorAction.default
        ) if api_credentials.first[:id] != @id_to_deactivate

        @deactivated_api_key = api_credentials.first[:api_key]

        success

      end

      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def deactivate

        ApiCredential.where(id: @id_to_deactivate).update_all(expiry_timestamp: current_timestamp)

        CacheManagement::ApiCredentials.new([@client_id]).clear([@deactivated_api_key])

        success

      end

    end

  end

end
