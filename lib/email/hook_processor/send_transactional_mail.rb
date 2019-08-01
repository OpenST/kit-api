module Email

  module HookProcessor

    class SendTransactionalMail < Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::SendTransactionalMail] returns an object of Email::HookProcessor::SendTransactionalMail class
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

      # Validate
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

        send_mail_params = @hook.params

        unless send_mail_params["template_vars"]["company_web_domain"].present?
          send_mail_params["template_vars"]["company_web_domain"] = CGI.escape(GlobalConstant::CompanyWeb.domain)
        end

        link = fetch_view_link(send_mail_params)

        send_mail_params["template_vars"]["view_link"] = CGI.escape(link) if link.present?

        send_mail_response = Email::Services::PepoCampaigns.new.send_transactional_email(
          @email,
          send_mail_params["template_name"],
          send_mail_params["template_vars"]
        )

        if send_mail_response['error'].present?
          error_with_data(
            'e_hp_stm_1',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            send_mail_response
          )
        else

          response = unset_client_statuses
          return response unless unset_client_statuses.success?

          success_with_data(send_mail_response)
        end

      end

      # Unset client statuses if stake and mint is done.
      #
      # * Author: Anagha
      # * Date: 01/08/2019
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def unset_client_statuses

        send_mail_params = @hook.params
        receiver_entity_id = @hook.receiver_entity_id

        if send_mail_params["template_name"] == GlobalConstant::PepoCampaigns.platform_stake_and_mint_status_success_template
          client = Client.where(id: receiver_entity_id).first

          sanbox_statuses = client[:sandbox_statuses].present? ? Client.get_bits_set_for_sandbox_statuses(client[:sandbox_statuses]) : []
          mainnet_statuses = client[:mainnet_statuses].present? ? Client.get_bits_set_for_mainnet_statuses(client[:mainnet_statuses]) : []

          if GlobalConstant::Base.sandbox_sub_environment?
            if sanbox_statuses.include?(GlobalConstant::Client.sandbox_low_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.sandbox_low_balance_email_property}")
            elsif sanbox_statuses.include?(GlobalConstant::Client.sandbox_very_low_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.sandbox_very_low_balance_email_property}")
            elsif sanbox_statuses.include?(GlobalConstant::Client.sandbox_zero_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.sandbox_zero_balance_email_property}")
            end
          elsif GlobalConstant::Base.main_sub_environment?
            if mainnet_statuses.include?(GlobalConstant::Client.mainnet_low_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.mainnet_low_balance_email_property}")
            elsif mainnet_statuses.include?(GlobalConstant::Client.mainnet_very_low_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.mainnet_very_low_balance_email_property}")
            elsif mainnet_statuses.include?(GlobalConstant::Client.mainnet_zero_balance_email_property)
              client.send("unset_#{GlobalConstant::Client.mainnet_zero_balance_email_property}")
            end
          end

          client.save!
        end

        success
      end

      # Add extra template vars
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def fetch_view_link(send_mail_params)
        return nil unless send_mail_params["template_vars"]["token_id"].present?

        token_id = send_mail_params["template_vars"]["token_id"].to_i # Cache expects this to be an integer

        client_mile_stone = ::ClientMileStone.new({})

        client_mile_stone.fetch_view_link(token_id, GlobalConstant::Environment.url_prefix)
      end

    end

  end

end
