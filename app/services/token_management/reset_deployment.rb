module TokenManagement

  class ResetDeployment < TokenManagement::Base

    # Initialize
    #
    # * Author: Shlok
    # * Date: 22/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

    end

    # Perform
    #
    # * Author: Shlok
    # * Date: 22/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        fetch_token_details

        reset_status

        success_with_data({})

      end
    end

    # Reset token status to not deployed in tokens table.
    #
    #
    # * Author: Shlok
    # * Date: 22/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details

      @token_details = Token.where(client_id: @client_id).first
      Util::EntityHelper.token_not_found_response("s_tm_rd_1") if @token_details.blank?

    end


    # Reset token status to not deployed in tokens table.
    #
    #
    # * Author: Shlok
    # * Date: 22/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def reset_status

      @token_details.status = GlobalConstant::ClientToken.not_deployed
      @token_details.save!

    end


  end

end