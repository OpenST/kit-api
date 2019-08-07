module Email

  module HookProcessor

    class RemoveContact < Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::RemoveContact] returns an object of Email::HookProcessor::RemoveContact class
      #
      def initialize(params)
        super

        @list_id = nil
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

      # validate
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        success

      end

      # Start processing hook
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook

        remove_contact_response = Email::Services::PepoCampaigns.new.remove_contact(
            list_id, @email
        )

        if remove_contact_response['error'].present?
          error_with_data(
              'e_hp_rc_1',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default,
              remove_contact_response
          )
        else
          success_with_data(remove_contact_response)
        end

      end

      # Return list id to use
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @return [Number]
      #
      def list_id
        @hook.params["list_id"].to_i
      end

    end

  end

end
