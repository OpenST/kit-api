module Email

  module HookCreator

    # This would be called to remove user from campaigns
    #
    class RemoveContact < Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @params [Number] list_id (mandatory) - list id from which user has to be deleted
      #
      # @return [Email::HookCreator::RemoveContact] returns an object of Email::HookCreator::RemoveContact class
      #
      def initialize(params)
        super

        @list_id = params[:list_id]
      end

      # Perform
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
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
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        validate_custom_variables

      end

      # Event type
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [String] event type that goes into hook table
      #
      def event_type
        GlobalConstant::EmailServiceApiCallHook.remove_contact_event_type
      end

      # create a hook to add contact
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def handle_event

        create_hook(
            list_id: @list_id
        )

        success

      end

    end

  end

end
