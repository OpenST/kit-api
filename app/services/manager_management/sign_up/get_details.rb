module ManagerManagement

  module SignUp

    class GetDetails < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @params [String] i_t (mandatory) - token if this user is signing up from via a manager invite link
      #
      # @return [ManagerManagement::SignUp::GetDetails]
      #
      def initialize(params)

        super

        @invite_token = @params[:i_t]

        @decrypted_invite_token = nil
        @manager_validation_hash = nil
        @utm_params = {}

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

          r = validate_and_sanitize
          return r unless r.success?

          r = decrypt_invite_token
          return r unless r.success?

          r = validate_invite_token
          return r unless r.success?

          r = fetch_and_validate_invited_manager
          return r unless r.success?

          r = fetch_client
          return r unless r.success?

          r = fetch_and_validate_inviter_manager
          return r unless r.success?

          r = fetch_token_details
          return r unless r.success?

          success_with_data(
            client: @client,
            token: @token,
            inviter_manager: {
              email: Util::CommonSanitizer.secure_email(@inviter_manager[:email])
            },
            invitee_manager: {
              email: Util::CommonSanitizer.secure_email(@manager_obj.email)
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

        # NOTE: To be on safe side, check for generic errors as well
        r = validate
        return r unless r.success?

        if @invite_token.present?

          @invite_token = @invite_token.to_s.strip

          unless Util::CommonValidator.is_valid_token?(@invite_token)

            return validation_error(
              'mm_su_gd_1',
              'invalid_api_params',
              ['invalid_i_t'],
              GlobalConstant::ErrorAction.default
            )
          end

        end

        success
      end


      # Fetch token details
      #
      # * Author: Anagha
      # * Date: 15/05/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_token_details

        @token = {}
        token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'a_s_mm_su_gd')

        if token_resp.success?
          @token = token_resp.data
        end

        success
      end

    end

  end

end