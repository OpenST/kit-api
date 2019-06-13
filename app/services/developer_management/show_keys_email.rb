module DeveloperManagement

  class ShowKeysEmail < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client_manager (mandatory) - Client Manager
    # @params [Integer] show_keys_enable_flag(optional) - show keys enable flag
    # @params [Integer] email_already_sent_flag(optional) - email already sent flag
    #
    # @return [DeveloperManagement::FetchDetails]
    #
    def initialize(params)

      super

      @email_already_sent_flag = @params[:email_already_sent_flag]

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 04/02/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        @api_response_data = {
          email_already_sent_flag: @email_already_sent_flag
        }

        success_with_data(@api_response_data)

      end
    end

  end
end