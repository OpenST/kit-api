module TestEconomyManagement

  class Get < TestEconomyManagement::Base

    # Initialize
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client (mandatory) - Client cache data
    # @params [String] auth_token (optional) - auth token to allow logged in user in main env to access test economy
    # @params [Hash] manager (mandatory) - Manager cache data
    #
    # @return [TestEconomyManagement::Get]
    #
    def initialize(params)
      super
    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return prepare_error_response unless r.success?

        r = fetch_token
        return prepare_error_response unless r.success?

        r = fetch_sub_env_payloads
        return r unless r.success?

        prepare_response

      end

    end

    private

    # Prepare error response
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By: Sunil
    #
    # @return [Result::Base]
    #
    def prepare_error_response

      if @token.blank?
        # dont check response here, as even if token wasn't found we want to proceed
        fetch_token
      end

      FetchGoToByEconomyState.new({
                                             token: @token,
                                             client_id: @client_id,
                                             from_page: GlobalConstant::GoTo.test_economy
                                         }).fetch_by_economy_state
    end

    # Prepare response
    #
    # * Author: Puneet
    # * Date: 10/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def prepare_response
      success_with_data(
        {
          token: @token,
          client: @client,
          manager: @manager,
          sub_env_payloads: @sub_env_payloads,
          test_economy_details: {
            qr_code_url: test_economy_qr_code_uploaded? ? qr_code_s3_url : nil,
            ios_app_download_link: GlobalConstant::DemoApp.ios_url,
            android_app_download_link: GlobalConstant::DemoApp.android_url
          }
        }
      )
    end

  end

end
