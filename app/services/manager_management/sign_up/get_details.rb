module ManagerManagement

  module SignUp

    class GetDetails < ManagerManagement::SignUp::Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 06/12/2018
      # * Reviewed By:
      #
      # @param [String] i_t (mandatory) - token if this user is signing up from via a manager invite link
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

          fetch_and_validate_inviter_manager

          success_with_data(
            client: @client,
            inviter_manager_id: @inviter_manager_id,
            invitee_manager_id: @manager_obj.id,
            managers: {
              @manager_obj.id => @manager_obj.formated_cache_data,
              @inviter_manager_id => @inviter_manager
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

          if !Util::CommonValidator.is_valid_token?(@invite_token)

            fail OstCustomError.new validation_error(
                                      'mm_su_gd_1',
                                      'invalid_api_params',
                                      ['invalid_i_t'],
                                      GlobalConstant::ErrorAction.default
                                    )
          end

        end

        # NOTE: To be on safe side, check for generic errors as well
        validate

      end

    end

  end

end