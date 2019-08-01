module Crons

  class LowBalanceEmail < SaasApi::Base

    include Util::ResultHelper

    def initialize
      super
    end

    # public method to process hooks
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def perform(params)

      @token = params[:token_row]
      @dashboard = nil
      @status_to_set = nil

      puts "Initialize ============ #{params[:token_row].inspect}"
      puts "In perform of low balance email"
      begin
        puts "In begin"

        r = get_dashboard_response
        return r unless r.success?

        puts " dashboard_service_response, #{r}"

        r = check_token_holders_balance
        return r unless r.success?

        r = check_client_details
        return r unless r.success?
      end

    end

    # public method to process hooks
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def get_dashboard_response
      #@token = Token.where(client_id:10433)

      #row = row[0]

      puts "row.@token[:client_id], #{@token[:client_id].inspect}"

      # When token is dissociated, client_id is null.
      return success if @token[:client_id].nil?

      dashboard_service_response = send_request_of_type(
        'get',
        GlobalConstant::SaasApi.get_dashboard,
        {client_id: @token[:client_id],  #10433
        token_id: @token[:id]} #   1283
      )

      puts "dashboard_service_response, #{dashboard_service_response.inspect}"

      return dashboard_service_response unless dashboard_service_response.success?

      @dashboard = dashboard_service_response[:data]

      success
    end

    # Check token holders balance and set status if required.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def check_token_holders_balance

      return success if @dashboard.nil?

      puts " dashboard_service_response_data, #{@dashboard.inspect}"

      token_holders_balance = @dashboard["tokenHoldersBalance"].to_f
      total_supply = @dashboard["totalSupply"].to_f

      puts " token_holders_balance, #{token_holders_balance.inspect}"
      puts " total_supply, #{total_supply.inspect}"

      if token_holders_balance == 0
        @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                           GlobalConstant::Client.sandbox_zero_balance_email_property :
                           GlobalConstant::Client.mainnet_zero_balance_email_property
      elsif (token_holders_balance) > (total_supply * 0.9) # Change this to 0.05
        @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                           GlobalConstant::Client.sandbox_very_low_balance_email_property :
                           GlobalConstant::Client.mainnet_very_low_balance_email_property
      elsif (token_holders_balance) < (total_supply * 0.99) # Change this to 0.1
        puts " Here here here #{total_supply.inspect}"
        @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                           GlobalConstant::Client.sandbox_low_balance_email_property :
                           GlobalConstant::Client.mainnet_low_balance_email_property
      end

      success
    end

    # Set status according to sub-environment.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def check_client_details
      puts "Inside check_client_details"

      return success if @status_to_set.nil?

      puts "Inside check_client_details ==========="

      client = CacheManagement::Client.new([@token[:client_id]]).fetch[@token[:client_id]]

      if (GlobalConstant::Base.sandbox_sub_environment? &&
        client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_stake_and_mint_property) &&
        !client[:sandbox_statuses].include?(@status_to_set)) ||
        (GlobalConstant::Base.main_sub_environment? &&
        client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_stake_and_mint_property) &&
        !client[:mainnet_statuses].include?(params[:mainnet_property]))

        email_hook_response = create_email_hook
        return email_hook_response unless email_hook_response.success?

        client_response = set_property_for_client
        return client_response unless client_response.success?
      end

      success
    end

    # Create email hook.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def create_email_hook
      puts "get_template_name(params[:property] #{get_template_name.inspect}"

      company_web_domain = CGI.escape(GlobalConstant::CompanyWeb.domain)
      url_prefix = GlobalConstant::Environment.url_prefix

      template_vars = {
        token_name: @token[:name],
        company_web_domain: company_web_domain,
        url_prefix: url_prefix
      }
      puts "template_vars #{template_vars}"

      super_admin_manager_ids = ClientManager.super_admins(@token[:client_id]).pluck(:manager_id)

      puts "super_admin_manager_ids #{super_admin_manager_ids}"
      super_admin_manager_ids.each do |manager_id|

        resp = Email::HookCreator::SendTransactionalMail.new(
          receiver_entity_id: manager_id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
          template_name: get_template_name,
          template_vars: template_vars).perform

        puts "resp #{resp}"
      end
      success
    end

    # Set status for client.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def set_property_for_client

      puts "@token[:client_id] #{@token[:client_id]}"

      puts "@@status_to_set #{@status_to_set}"

      client_obj = ::Client.where(id: @token[:client_id]).first
      client_obj.send("set_#{@status_to_set}")
      client_obj.save!

      success
    end

    # Get template name according to status.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def get_template_name
      puts " @status_to_set #{@status_to_set}"

      case @status_to_set
      when GlobalConstant::Client.sandbox_very_low_balance_email_property,
        GlobalConstant::Client.mainnet_very_low_balance_email_property
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_5
      when GlobalConstant::Client.sandbox_low_balance_email_property,
        GlobalConstant::Client.mainnet_low_balance_email_property
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_10
      when GlobalConstant::Client.sandbox_zero_balance_email_property,
        GlobalConstant::Client.mainnet_zero_balance_email_property
        return GlobalConstant::PepoCampaigns.platform_low_token_balance_0
      else
        fail "Invalid status"
      end
    end

  end

end