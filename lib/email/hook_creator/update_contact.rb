module Email

  module HookCreator

    class UpdateContact < Base

      # Initialize
      #
      # * Author: Pankaj
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @params [Hash] custom_attributes (optional) - attribute which are to be set for this email
      # @params [String] custom_description (optional) - description which would be logged in email service hooks table
      # @params [Hash] user_Settings (optional) - user settings which has to be updated for this email
      #
      # @return [Email::HookCreator::UpdateContact] returns an object of Email::HookCreator::UpdateContact class
      #
      def initialize(params)
        super
        @user_settings = params[:user_settings] || {}
      end

      # Perform
      #
      # * Author: Pankaj
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def perform
        super
      end

      private

      # Validate
      #
      # * Author: Pankaj
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        return validation_error(
            'e_hc_uc_1',
            'invalid_api_params',
            ['missing_email'],
            GlobalConstant::ErrorAction.default
        ) if @email.blank?

        validate_custom_variables

      end

      # Event type
      #
      # * Author: Pankaj
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [String] event type that goes into hook table
      #
      def event_type
        GlobalConstant::EmailServiceApiCallHook.update_contact_event_type
      end

      # create a hook to add contact
      #
      # * Author: Pankaj
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def handle_event

        create_hook(
          custom_attributes: @custom_attributes,
          user_settings: @user_settings
        )

        success

      end

    end

  end

end
