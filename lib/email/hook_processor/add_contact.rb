module Email

  module HookProcessor

    class AddContact < Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::AddContact] returns an object of Email::HookProcessor::AddContact class
      #
      def initialize(params)
        super
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

      # validate
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        success

      end

      # Start processing hook
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook

        add_contact_response = Email::Services::PepoCampaigns.new.add_contact(
          *add_update_contact_params
        )

        if add_contact_response['error'].present?
          error_with_data(
            'e_hp_ac_1',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            add_contact_response
          )
        else
          success_with_data(add_contact_response)
        end

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
        @hook.params[:custom_attributes] || {}
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
        {
            GlobalConstant::PepoCampaigns.double_opt_in_status_user_setting => GlobalConstant::PepoCampaigns.verified_value,
            GlobalConstant::PepoCampaigns.subscribe_status_user_setting => GlobalConstant::PepoCampaigns.subscribed_value
        }
      end

    end

  end

end
