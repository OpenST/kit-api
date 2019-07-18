module Email

  module HookProcessor

    class ClientMileStone < Base

      # Initialize
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      # @return [Email::HookProcessor::ClientMileStone] returns an object of Email::HookProcessor::ClientMileStone class
      #
      def initialize(params)
        super
      end

      # Perform
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
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
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        return error_with_data(
            'e_hp_cms_1',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            { mile_stone: mile_stone }
        ) unless mile_stone.present?

        success
      end

      # Start processing hook
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook

        r = set_client_properties
        return r unless r.success?

        r = update_super_admins
        return r unless r.success?

      end

      # Set client properties
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_client_properties
        @client_id = @hook[:receiver_entity_id]

        client = Client.where(id: @client_id).first
        client.send("set_#{mile_stone}")
        client.save!

        success
      end

      # Update properties on super admins
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_super_admins
        ClientManager.admins(@client_id).all.each do |client_manager|
          client_manager.send("set_#{mile_stone}")
          client_manager.save!

          Email::HookCreator::UpdateContact.new(
              receiver_entity_id: client_manager[:manager_id],
              receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
              custom_attributes: attributes_hash,
              user_settings: {}
          ).perform
        end

        success
      end

      # Build attributes for email service
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def attributes_hash
        @hook.params["custom_attributes"] || {}
      end

      # Build user settings for email service
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def user_settings_hash
        @hook.params["user_settings"] || {}
      end

      # attribute name to be updated
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def mile_stone
        @hook.params["mile_stone"]
      end

    end

  end

end
