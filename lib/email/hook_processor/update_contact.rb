module Email

  module HookProcessor

    class UpdateContact < Base

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

        fetch_campaign_automation_attributes if client_id.present? && manager_id.present?

        update_contact_response = Email::Services::PepoCampaigns.new.update_contact(
          *add_update_contact_params
        )

        if update_contact_response['error'].present?
          error_with_data(
            'e_hp_ac_1',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            update_contact_response
          )
        else
          success_with_data(update_contact_response)
        end

      end

      # Fetch campaign automation attributes
      #
      # * Author: Santhosh
      # * Date: 26/07/2019
      # * Reviewed By:
      #
      # @returns [Hash]
      #
      def fetch_campaign_automation_attributes
        campaign_attribute_manager = CampaignAttributeManager.new({ client_id: client_id, manager_id: manager_id })

        r = campaign_attribute_manager.fetch_automation_campaign_attributes
        return r unless r.success?

        attr_hash = r.data
        attributes_hash.merge!(attr_hash)
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
        @hook.params["custom_attributes"] || {}
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
        @hook.params["user_settings"] || {}
      end

      # Client id
      #
      # * Author: Santhosh
      # * Date: 01/08/2019
      # * Reviewed By:
      #
      # @return [Number]
      #
      def client_id
        @hook.params["client_id"]
      end

      # Manager id
      #
      # * Author: Santhosh
      # * Date: 01/08/2019
      # * Reviewed By:
      #
      # @return [Number]
      #
      def manager_id
        @hook.params["manager_id"]
      end

    end

  end

end
