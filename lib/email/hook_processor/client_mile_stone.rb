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
        @first_stake_and_mint = nil
        @attributes_hash = {}
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

        r = check_first_time_stake_and_mint
        return r unless r.success?

        fetch_property_to_set

        r = set_unset_client_properties
        return r unless r.success?

        r = update_mile_stone_attributes_for_admins
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

      # Check first time stake and mint.
      #
      # * Author: Anagha
      # * Date: 01/08/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def check_first_time_stake_and_mint
        @sandbox_statuses = @client[:sandbox_statuses].present? ? Client.get_bits_set_for_sandbox_statuses(@client[:sandbox_statuses]) : []
        @mainnet_statuses = @client[:mainnet_statuses].present? ? Client.get_bits_set_for_mainnet_statuses(@client[:mainnet_statuses]) : []


        if (GlobalConstant::Base.sandbox_sub_environment? &&
          @sandbox_statuses.include?(GlobalConstant::Client.sandbox_stake_and_mint_property)) ||
          (GlobalConstant::Base.main_sub_environment? &&
            @mainnet_statuses.include?(GlobalConstant::Client.mainnet_stake_and_mint_property))
          @first_stake_and_mint = true

        end

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
      def set_unset_client_properties

        if GlobalConstant::Base.sandbox_sub_environment? &&
          mile_stone == GlobalConstant::Client.sandbox_stake_and_mint_property
          if @sandbox_statuses.include?(GlobalConstant::Client.sandbox_low_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.sandbox_low_balance_email_status}")
          elsif @sandbox_statuses.include?(GlobalConstant::Client.sandbox_very_low_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.sandbox_very_low_balance_email_status}")
          elsif @sandbox_statuses.include?(GlobalConstant::Client.sandbox_zero_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.sandbox_zero_balance_email_status}")
          end
        elsif GlobalConstant::Base.main_sub_environment? &&
          mile_stone == GlobalConstant::Client.mainnet_stake_and_mint_property
          if @mainnet_statuses.include?(GlobalConstant::Client.mainnet_low_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.mainnet_low_balance_email_status}")
          elsif @mainnet_statuses.include?(GlobalConstant::Client.mainnet_very_low_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.mainnet_very_low_balance_email_status}")
          elsif @mainnet_statuses.include?(GlobalConstant::Client.mainnet_zero_balance_email_status)
            @client.send("unset_#{GlobalConstant::Client.mainnet_zero_balance_email_status}")
          end
        end

        @client.send("set_#{@property_to_set}")
        @client.save!

        success
      end


      # Update client mile stone attributes for all admins in pepo campaigns
      #
      # * Author: Santhosh
      # * Date: 30/07/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def update_mile_stone_attributes_for_admins

        if @first_stake_and_mint
          if mile_stone == GlobalConstant::Client.mainnet_stake_and_mint_property ||
            mile_stone == GlobalConstant::Client.sandbox_stake_and_mint_property
            return success
          end
        end

        manager_ids = []
        super_admins = {}

        ClientManager.admins(@client_id).all.each do |client_manager|
          formatted_cm = client_manager.formatted_cache_data
          manager_ids << client_manager[:manager_id]
          super_admins[client_manager[:manager_id]] = 1 if formatted_cm[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_privilege)
        end

        managers = CacheManagement::Manager.new(manager_ids).fetch

        # Only active managers should have the mile stones updated in pepo campaigns
        managers.each do |manager_id, manager|
          next if manager[:status] != GlobalConstant::Manager.active_status

          r = Email::HookCreator::UpdateContact.new(
              receiver_entity_id: manager_id,
              receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
              custom_attributes: {},
              user_settings: {},
              client_id: @client_id,
              manager_id: manager_id
          ).perform

          @failed_logs[manager_id] = r.to_hash unless r.success?
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
        {}
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
        {}
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
