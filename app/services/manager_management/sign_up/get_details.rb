module ManagerManagement

  module SignUp

    class GetDetails < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [String] i_t (optional) - token if this user is signing up from via a manager invite link
      #
      # @return [ManagerManagement::SignUp::GetDetails]
      #
      def initialize(params)

        super

        @invite_token = @params[:i_t]

        @decrypted_invite_token = nil
        @manager_validation_hash = nil

      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          validate_and_sanitize

          decrypt_invite_token

          validate_invite_token

          fetch_and_validate_invited_manager

          fetch_and_validate_client

          success_with_data(
            client: @client,
            invited_manager: {
              email: @manager_obj.email.gsub(/.{0,4}@/, '####@')
            }
          )

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        if @invite_token.present?
          @invite_token = @invite_token.to_s.strip
        end

        # NOTE: To be on safe side, check for generic errors as well
        validate

      end

    end

  end

end