class LowBalanceEmail

  include Util::ResultHelper

  def initialize(params)

    @client_id = params[:client_id]
    @token_id = params[:token_id]
    @token_name = params[:token_name]
    @dashboard = nil
    @status_to_set = nil
    @is_hook_creation_required = nil
  end

  # Performer method.
  #
  # * Author: Anagha
  # * Date: 01/08/2019
  # * Reviewed By:
  #
  def perform
    puts "In perform of low balance email"

    begin

      r = get_dashboard_response
      return r unless r.success?

      puts " dashboard_service_response, #{r}"

      r = check_token_holders_balance
      return r unless r.success?

      r = check_client_status
      return r unless r.success?

      r = create_email_hook
      return r unless r.success?

      r = set_status_for_client
      return r unless r.success?

    end

  end

  # Get dashboard response.
  #
  # * Author: Anagha
  # * Date: 01/08/2019
  # * Reviewed By:
  #
  def get_dashboard_response
    puts "client_id ===== #{@client_id}"

    # When token is dissociated, client_id is null.
    return success if @client_id.nil?

    dashboard_service_response = SaasApi::Dashboard::Get.new.perform({client_id: @client_id,
      token_id: @token_id})

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

    if token_holders_balance <= 1
      @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                         GlobalConstant::Client.sandbox_zero_balance_email_status :
                         GlobalConstant::Client.mainnet_zero_balance_email_status
    elsif (token_holders_balance) <= (total_supply * 0.05)
      @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                         GlobalConstant::Client.sandbox_very_low_balance_email_status :
                         GlobalConstant::Client.mainnet_very_low_balance_email_status
    elsif (token_holders_balance) <= (total_supply * 0.1)
      @status_to_set = GlobalConstant::Base.sandbox_sub_environment? ?
                         GlobalConstant::Client.sandbox_low_balance_email_status :
                         GlobalConstant::Client.mainnet_low_balance_email_status
    end

    success
  end

  # Set status according to sub-environment.
  #
  # * Author: Anagha
  # * Date: 01/08/2019
  # * Reviewed By:
  #
  def check_client_status

    puts "@status_to_set , #{@status_to_set}"

    return success if @status_to_set.nil?

    client = CacheManagement::Client.new([@client_id]).fetch[@client_id]

    puts "client from cache ==== #{client}"

    # Create email hook only if client has done stake and mint at least once.
    if (GlobalConstant::Base.sandbox_sub_environment? &&
      client[:sandbox_statuses].include?(GlobalConstant::Client.sandbox_stake_and_mint_property) &&
      !client[:sandbox_statuses].include?(@status_to_set)) ||
      (GlobalConstant::Base.main_sub_environment? &&
      client[:mainnet_statuses].include?(GlobalConstant::Client.mainnet_stake_and_mint_property) &&
      !client[:mainnet_statuses].include?(@status_to_set))

        @is_hook_creation_required = true

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

    puts "@is_hook_creation_required ====== #{@is_hook_creation_required}"
    # Return if hook creation is not required.
    return success if @is_hook_creation_required.nil?

    template_vars = {
      token_name: @token_name,
      company_web_domain: CGI.escape(GlobalConstant::CompanyWeb.domain),
      url_prefix: GlobalConstant::Environment.url_prefix,
      subject_prefix: GlobalConstant::PepoCampaigns.subject_prefix
    }

    super_admin_manager_ids = ClientManager.super_admins(@client_id).pluck(:manager_id)

    puts "template_vars #{template_vars}"
    puts "super_admin_manager_ids #{super_admin_manager_ids}"
    super_admin_manager_ids.each do |manager_id|

      email_hook_creation_resp = Email::HookCreator::SendTransactionalMail.new(
        receiver_entity_id: manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        template_name: get_template_name,
        template_vars: template_vars).perform

      puts "email_hook_creation_resp ====== #{email_hook_creation_resp}"

      return email_hook_creation_resp unless email_hook_creation_resp.success?
    end

    success
  end

  # Set status for client.
  #
  # * Author: Anagha
  # * Date: 01/08/2019
  # * Reviewed By:
  #
  def set_status_for_client

    return success if @is_hook_creation_required.nil?

    puts "@client_id #{@client_id}"
    puts "@status_to_set #{@status_to_set}"

    set_props_arr = [@status_to_set]

    Client.atomic_update_bitwise_columns(@client_id, set_props_arr, [])

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
    when GlobalConstant::Client.sandbox_very_low_balance_email_status,
      GlobalConstant::Client.mainnet_very_low_balance_email_status
      return GlobalConstant::PepoCampaigns.platform_low_token_balance_5
    when GlobalConstant::Client.sandbox_low_balance_email_status,
      GlobalConstant::Client.mainnet_low_balance_email_status
      return GlobalConstant::PepoCampaigns.platform_low_token_balance_10
    when GlobalConstant::Client.sandbox_zero_balance_email_status,
      GlobalConstant::Client.mainnet_zero_balance_email_status
      return GlobalConstant::PepoCampaigns.platform_low_token_balance_0
    else
      fail "Invalid status"
    end
  end

end