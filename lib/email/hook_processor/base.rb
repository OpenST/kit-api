module Email

  module HookProcessor

    class Base

      include Util::ResultHelper

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::Base] returns an object of Email::HookProcessor::Base class
      #
      def initialize(hook)
        @hook = hook
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

        r = validate
        return r unless r.success?

        process_hook

      end

      private

      # sub classes to implement logic of validating here
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate
        fail 'sub class to implement'
      end

      # sub classes to implement logic of processing hook here
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook
        fail 'sub class to implement'
      end

      # builds params which go into API call to Email Service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Array]
      #
      def add_update_contact_params
        [
          GlobalConstant::PepoCampaigns.master_list_id,
          @hook.email,
          attributes_hash,
          user_settings_hash
        ]
      end

      # Build attributes for email service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def attributes_hash
        fail 'sub class to implement'
      end

      # Build user settings for email service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def user_settings_hash
        fail 'sub class to implement'
      end

    end

  end

end