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

        r = fetch_client
        return r unless r.success?

        return success if @client_hash["#{sub_env}_statuses"].present? && @client_hash["#{sub_env}_statuses"].include?("#{sub_env}_#{mile_stone}")

        r = set_client_properties
        return r unless r.success?

        r = update_super_admins_and_admins
        return r unless r.success?

      end

      # Fetch client
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_client
        @client_id = @hook[:receiver_entity_id]

        @client = Client.where(id: @client_id).first

        @client_hash = @client.formatted_cache_data

        success
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

        @client.send("set_#{sub_env}_#{mile_stone}")
        @client.save!

        success
      end

      # Update properties on super admins and admins
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_super_admins_and_admins
        return success if sub_env != GlobalConstant::Environment.sandbox_sub_environment

        ClientManager.admins(@client_id).all.each do |client_manager|

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
      # @return [string]
      #
      def mile_stone
        @hook.params["mile_stone"]
      end

      # sub env in which hook was created
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [string]
      #
      def sub_env
        @hook.params["sub_env"]
      end

    end

  end

end
