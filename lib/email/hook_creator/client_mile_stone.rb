module Email

  module HookCreator

    class ClientMileStone < Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @params [Hash] user_settings (optional) - user settings which has to be updated for this email
      # @params [String] mile_stone (mandatory) - mile stone
      # @params [String] sub_env (mandatory) - sub env
      #
      # @return [Email::HookCreator::ClientMileStone] returns an object of Email::HookCreator::ClientMileStone class
      #
      def initialize(params)
        super
        @user_settings = params[:user_settings] || {}
        @mile_stone = params[:mile_stone]
        @sub_env = params[:sub_env]
      end

      # Perform
      #
      # * Author: Puneet
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
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        validate_custom_variables

      end

      # Event type
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [String] event type that goes into hook table
      #
      def event_type
        GlobalConstant::EmailServiceApiCallHook.client_mile_stone_event_type
      end

      # create a hook to add contact
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def handle_event

        create_hook(
            custom_attributes: @custom_attributes,
            user_settings: @user_settings,
            mile_stone: @mile_stone,
            sub_env: @sub_env
        )

        success

      end

    end

  end

end
