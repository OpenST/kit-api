module Crons

  class LowBalanceEmail < SaasApi::Base

    include Util::ResultHelper

    # public method to process hooks
    #
    # * Author: Puneet
    # * Date: 11/11/2017
    # * Reviewed By:
    #
    def perform

      begin

        # acquire lock and fetch the locked hooks
        fetch_token

      end

    end

    def fetch_token
      Token.find_in_batches(batch_size: 20) do |token_batches|

        token_batches.each do |row|
          Rails.logger.info(row.id)

          dashboard_service_response = send_request_of_type(
            'get',
            GlobalConstant::SaasApi.get_dashboard,
            {client_id:10433, # row.client_id
            token_id:1283} # row.id
          )

          return dashboard_service_response unless dashboard_service_response.success?

          Rails.logger.info(" response, #{dashboard_service_response}")

          dashboard_service_response_data = dashboard_service_response[:data]

          Rails.logger.info(" dashboard_service_response_data, #{dashboard_service_response_data}")

          token_holders_balance = dashboard_service_response_data["tokenHoldersBalance"].to_f
          total_supply = dashboard_service_response_data["totalSupply"].to_f

          Rails.logger.info(" token_holders_balance, #{token_holders_balance}")
          Rails.logger.info(" total_supply, #{total_supply}")
          Rails.logger.info(" row.client_id, #{row.client_id}")
          Rails.logger.info(" GlobalConstant::Client.sandbox_zero_balance_email_property, #{GlobalConstant::Client.sandbox_zero_balance_email_property}")
          Rails.logger.info(" GlobalConstant::Client.mainnet_zero_balance_email_property, #{GlobalConstant::Client.mainnet_zero_balance_email_property}")
          Rails.logger.info(" row.row.name, #{row.name}")

          if token_holders_balance == 0
            check_client_details({
              client_id: row.client_id,
              sandbox_property: GlobalConstant::Client.sandbox_zero_balance_email_property,
              mainnet_property: GlobalConstant::Client.mainnet_zero_balance_email_property,
              token_name: row.name})

          elsif (token_holders_balance) > (total_supply * 0.05) # Change > => <
            check_client_details({
              client_id: row.client_id,
              sandbox_property: GlobalConstant::Client.sandbox_very_low_balance_email_property,
              mainnet_property: GlobalConstant::Client.mainnet_very_low_balance_email_property,
              token_name: row.name})


          elsif (token_holders_balance) < (total_supply * 0.1)

            check_client_details({
              client_id:row.client_id,
              sandbox_property: GlobalConstant::Client.sandbox_low_balance_email_property,
              mainnet_property: GlobalConstant::Client.mainnet_low_balance_email_property,
              token_name: row.name})
          end

        return
        end
        Rails.logger.info("Batch complete")

      end
    end

    def check_client_details(params)

      Rails.logger.info("params, #{params}")

      client = CacheManagement::Client.new([params[:client_id]]).fetch[params[:client_id]]
      Rails.logger.info(" client, #{params[:client_id]}")


      if GlobalConstant::Base.sandbox_sub_environment? &&
        client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_stake_and_mint_property) &&
        !client[:sandbox_statuses].include?(params[:sandbox_property])

        email_hook_response = create_email_hook({
            token_name: params[:token_name],
            client_id: params[:client_id],
            property: params[:sandbox_property]})

        Rails.logger.info(" email_hook_response, #{email_hook_response.inspect}")

        return email_hook_response unless email_hook_response.success?

      elsif GlobalConstant::Base.main_sub_environment? &&
        client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_stake_and_mint_property) &&
        !client[:mainnet_statuses].include?(params[:mainnet_property])
        # Insert into email hook
        # Set client property

        email_hook_response = create_email_hook({
                                                  token_name: params[:token_name],
                                                  client_id: params[:client_id],
                                                  property: params[:mainnet_property]})

        return email_hook_response unless email_hook_response.success?

      end
    end

    def create_email_hook(params)
      Rails.logger.info(" create_email_hook params #{params.inspect}")

      Rails.logger.info("get_template_name(params[:property] #{get_template_name(params[:property])}")

      company_web_domain = CGI.escape(GlobalConstant::CompanyWeb.domain)
      url_prefix = GlobalConstant::Environment.url_prefix
      template_vars = [ params[:token_name], company_web_domain, url_prefix]

      Email::HookCreator::SendTransactionalMail.new(
        receiver_entity_id: params[:client_id],
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.client_receiver_entity_kind,
        template_name: get_template_name(params[:property]),
        template_vars: template_vars).perform
    end

    def get_template_name(property)
      Rails.logger.info(" property #{property}")

      case property
      when GlobalConstant::Client.sandbox_very_low_balance_email_property, GlobalConstant::Client.mainnet_very_low_balance_email_property
        Rails.logger.info(" Inside GlobalConstant::Client.sandbox_very_low_balance_email_property")
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_5
      when GlobalConstant::Client.sandbox_low_balance_email_property, GlobalConstant::Client.mainnet_low_balance_email_property
        Rails.logger.info(" Inside GlobalConstant::Client.sandbox_very_low_balance_email_property")
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_10
      when GlobalConstant::Client.sandbox_zero_balance_email_property, GlobalConstant::Client.mainnet_zero_balance_email_property
        Rails.logger.info(" Inside GlobalConstant::Client.sandbox_very_low_balance_email_property")
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_0
      else
        fail "no expiry found for : #{self.kind}"
      end
    end



  end

end