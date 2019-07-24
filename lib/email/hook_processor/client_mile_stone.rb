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

        @mile_stone = nil
        @failed_logs = {}
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

        set_mile_stone

        statuses_column_sym = "#{sub_env}_statuses".to_sym
        return success if @client_hash[statuses_column_sym].present? && @client_hash[statuses_column_sym].include?(@mile_stone)

        r = set_client_properties
        return r unless r.success?

        r = update_super_admins_and_admins
        return r unless r.success?

        notify_devs

        success
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

      # Set mile stone
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_mile_stone
        # TODO - Santhosh - use if else instead of meta
        if mile_stone.end_with?(GlobalConstant::Client.sandbox_registered_in_mappy_server_status[-15,15]) # using last 15 chars
          @mile_stone = mile_stone
        else
          @mile_stone = "#{sub_env}_#{mile_stone}"
        end
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
        # TODO - Santhosh - use if else instead of meta
        @client.send("set_#{@mile_stone}")
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
        # TODO - change name of the method to in_pepo_campaign
        # and add comments
        return success if sub_env != GlobalConstant::Environment.sandbox_sub_environment

        ClientManager.admins(@client_id).all.each do |client_manager|

          r = Email::HookCreator::UpdateContact.new(
              receiver_entity_id: client_manager[:manager_id],
              receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
              custom_attributes: attributes_hash,
              user_settings: {}
          ).perform

          @failed_logs[client_manager[:manager_id]] = r.to_hash unless r.success?
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

      # Send notification mail
      #
      # * Author: Santhosh
      # * Date: 22/07/2019
      # * Reviewed By:
      #
      def notify_devs
        ApplicationMailer.notify(
            data: @failed_logs,
            body: {},
            subject: 'Exception in client mile stone hook creation'
        ).deliver if @failed_logs.present?
      end

    end

  end

end
