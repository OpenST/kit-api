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

        @property_to_set = nil
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

        fetch_property_to_set

        statuses_column_sym = "#{sub_env}_statuses".to_sym
        return success if @client_hash[statuses_column_sym].present? && @client_hash[statuses_column_sym].include?(@property_to_set)

        r = set_client_properties
        return r unless r.success?

        r = add_extra_attributes
        return r unless r.success?

        r = update_super_admins_and_admins_in_pepo_campaign
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

      # Fetch property to set
      #
      # * Author: Santhosh
      # * Date: 17/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_property_to_set

        case mile_stone
        when GlobalConstant::PepoCampaigns.ost_wallet_setup
          @property_to_set = GlobalConstant::Base.sandbox_sub_environment? ? GlobalConstant::Client.sandbox_registered_in_mappy_server_status : GlobalConstant::Client.mainnet_registered_in_mappy_server_status
        when GlobalConstant::PepoCampaigns.token_setup
          @property_to_set = GlobalConstant::Base.sandbox_sub_environment? ? GlobalConstant::Client.sandbox_token_setup_property : GlobalConstant::Client.mainnet_token_setup_property
        when GlobalConstant::PepoCampaigns.stake_and_mint
          @property_to_set = GlobalConstant::Base.sandbox_sub_environment? ? GlobalConstant::Client.sandbox_stake_and_mint_property : GlobalConstant::Client.mainnet_stake_and_mint_property
        when GlobalConstant::PepoCampaigns.ost_wallet_invited_users
          @property_to_set = GlobalConstant::Base.sandbox_sub_environment? ? GlobalConstant::Client.sandbox_ost_wallet_invited_users_property : GlobalConstant::Client.mainnet_ost_wallet_invited_users_property
        else
          fail "Invalid mile stone : #{mile_stone}"
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
        @client.send("set_#{@property_to_set}")
        @client.save!

        success
      end

      # Add extra attributes - token_name, testnet_view_link
      #
      # * Author: Santhosh
      # * Date: 25/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def add_extra_attributes
        client_mile_stone = ::ClientMileStone.new(client_id: @client_id)

        r = client_mile_stone.add_extra_attributes
        return r unless r.success?

        attributes_hash.merge!(r.data)

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
      def update_super_admins_and_admins_in_pepo_campaign
        return success if sub_env != GlobalConstant::Environment.sandbox_sub_environment # Update only for testnet

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

      # Token id - in case of token setup mile stone
      #
      # * Author: Santhosh
      # * Date: 25/07/2019
      # * Reviewed By:
      #
      # @return [Number]
      #
      def token_id
        @hook.params["token_id"]
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
