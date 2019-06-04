module ClientManagement

  module ApiCredentials

    class Fetch < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By: Sunil
      #
      # @params [Integer] client_id (mandatory) - Client Id for which Api credentials has to be fetched
      # @params [Integer] show_keys_enable_flag(optional) - show keys enable flag
      # @params [Integer] email_already_sent_flag(optional) - email already sent flag
      #
      # @return [ClientManagement::ApiCredentials::Fetch]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]

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

          if @show_keys_enable_flag == 1 && @email_already_sent_flag == 1
            r = fetch_api_credentials
            return r unless r.success?
          end

          success_with_data(
            {
              api_keys: @api_credentials_data,
              email_already_sent_flag: @email_already_sent_flag,
              show_keys_enable_flag: @show_keys_enable_flag
            })

        end

      end

      # Validate and sanitize given parameters
      #
      # * Author: Ankit
      # * Date: 05/02/2019
      # * Reviewed By: Sunil
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
      # * Author: Ankit
      # * Date: 05/02/2019
      # * Reviewed By: Sunil
      #
      # @return [Result::Base]
      #
      def fetch_api_credentials

        api_credentials = KitSaasSharedCacheManagement::ApiCredentials.new([@client_id]).fetch[@client_id]
        if api_credentials.length == 0
          return error_with_data(
                   's_cm_ac_f_4',
                   'something_went_wrong',
                   GlobalConstant::ErrorAction.default,
                   @client_id
          )
        end

        @api_credentials_data = api_credentials

        success
      end

    end

  end

end
