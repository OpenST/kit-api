class CampaignAttributeManager

  include Util::ResultHelper

  # Initialize
  #
  # @params [Number] client_id (mandatory) - client id
  # @params [Number] manager_id (optional) - manager id
  #
  # @return [ClientMileStone]
  #
  def initialize(params)
    @client_id = params[:client_id]
    @manager_id = params[:manager_id]

    @attributes_hash = {}
  end

  # Fetch automation campaign attributes
  #
  # * Author: Santhosh
  # * Date: 29/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_automation_campaign_attributes
    r = fetch_client_mile_stones
    return r unless r.success?

    success_with_data(@attributes_hash)
  end


  # Add view link - view_link
  #
  # * Author: Santhosh
  # * Date: 25/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_view_link(token_id, url_prefix)

    addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).fetch

    return nil unless addresses_data[token_id].present? && addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract].present?

    ubt_data = addresses_data[token_id][GlobalConstant::TokenAddresses.utility_branded_token_contract]

    ubt_contract_address = ubt_data[:address]

    deployed_chain_id = ubt_data[:deployed_chain_id]

    "#{GlobalConstant::CompanyOtherProductUrls.view_root_url}/#{url_prefix}/token/ec-#{deployed_chain_id}-#{ubt_contract_address}"
  end

  private

  # Fetch client mile stones reached
  #
  # * Author: Santhosh
  # * Date: 16/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_client_mile_stones

    fetch_super_admin_attribute if @client_id.present? && @manager_id.present?

    client_mile_stones = Client.sandbox_client_mile_stones

    client = CacheManagement::Client.new([@client_id]).fetch[@client_id]

    set_mile_stones = []

    client_mile_stones.each do |mile_stone, _|
      set_mile_stones << mile_stone if client[:sandbox_statuses].present? && client[:sandbox_statuses].include?(mile_stone)
    end

    # Extra attributes not to be set on mainnet
    return success_with_data({ set_mile_stones: [] }) if set_mile_stones.length == 0

    fetch_attributes_to_set(set_mile_stones)

    r = add_extra_attributes
    return r unless r.success?

    @attributes_hash.merge!(r.data)

    success_with_data({ set_mile_stones: set_mile_stones })
  end

  # Fetch super admin privilege
  #
  # * Author: Santhosh
  # * Date: 24/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_super_admin_attribute

    client_manager = CacheManagement::ClientManager.new([@manager_id],
                                                        { client_id: @client_id }).fetch[@manager_id]

    if client_manager[:privileges].include?(GlobalConstant::ClientManager.is_super_admin_privilege)
      @attributes_hash[:super_admin] = GlobalConstant::PepoCampaigns.attribute_set
    else
      @attributes_hash[:super_admin] = GlobalConstant::PepoCampaigns.attribute_unset
    end

    success
  end


  # Fetch attributes to be set
  #
  # * Author: Santhosh
  # * Date: 24/07/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def fetch_attributes_to_set(set_mile_stones)
    @attributes_hash = {}

    set_mile_stones.each do |mile_stone_property|
      case mile_stone_property
      when GlobalConstant::Client.sandbox_registered_in_mappy_server_status
        @attributes_hash[GlobalConstant::PepoCampaigns.ost_wallet_setup] = GlobalConstant::PepoCampaigns.attribute_set
      when GlobalConstant::Client.sandbox_token_setup_property
        @attributes_hash[GlobalConstant::PepoCampaigns.token_setup] = GlobalConstant::PepoCampaigns.attribute_set
      when GlobalConstant::Client.sandbox_stake_and_mint_property
        @attributes_hash[GlobalConstant::PepoCampaigns.stake_and_mint] = GlobalConstant::PepoCampaigns.attribute_set
      when GlobalConstant::Client.sandbox_ost_wallet_invited_users_property
        @attributes_hash[GlobalConstant::PepoCampaigns.ost_wallet_invited_users] = GlobalConstant::PepoCampaigns.attribute_set
      else
        fail "Invalid mile stone property : #{mile_stone_property}"
      end
    end

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
    extra_attributes = {}

    token_details = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]

    if token_details.blank? || (token_details.present? && token_details[:status] != GlobalConstant::ClientToken.deployment_completed)
      return success_with_data({})
    end

    token_id = token_details[:id]

    extra_attributes[GlobalConstant::PepoCampaigns.token_name] = token_details[:name]

    extra_attributes[GlobalConstant::PepoCampaigns.testnet_view_link] = fetch_view_link(token_id, GlobalConstant::Environment.testnet_url_prefix)

    success_with_data(extra_attributes)
  end
end