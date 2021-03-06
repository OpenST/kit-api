module ManagerManagement

  module Team

    class Get < ServicesBase

      # Initialize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @params [Integer] client_id (mandatory) - Client Id
      # @params [Integer] page_no (optional) - Page no.
      #
      # @return [ManagerManagement::Team::Get]
      #
      def initialize(params)

        super

        @client_id = @params[:client_id]
        @manager = @params[:manager]
        @client = @params[:client]
        @client_manager = @params[:client_manager]

        @api_response_data = {}

      end

      # Perform
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_sub_env_payloads
          return r unless r.success?

          success_with_data(
              {
                  manager: @manager,
                  client: @client,
                  client_manager: @client_manager,
                  sub_env_payloads: @sub_env_payloads
              })

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Shlok
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        success

      end

      # fetch the sub env response data entity
      #
      # * Author: Ankit
      # * Date: 01/02/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_sub_env_payloads
        r = SubEnvPayload.new({client_id:@client_id}).perform
        return r unless r.success?

        @sub_env_payloads = r.data[:sub_env_payloads]

        success
      end

    end

  end

end
