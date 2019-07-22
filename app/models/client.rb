class Client < DbConnection::KitClient

  def self.properties_config
    @c_props ||= {
        GlobalConstant::Client.has_enforced_mfa_property => 1,
        GlobalConstant::Client.has_mobile_app_property => 2,
        GlobalConstant::Client.has_one_million_users_property => 4,
        GlobalConstant::Client.has_company_info_property => 8
    }
  end

  def self.mainnet_statuses_config
    @c_m_statuses ||= {
        GlobalConstant::Client.mainnet_whitelisted_status => 1,
        GlobalConstant::Client.mainnet_whitelist_requested_status => 2,
        GlobalConstant::Client.mainnet_test_economy_qr_code_uploaded_status => 4,
        GlobalConstant::Client.mainnet_registered_in_mappy_server_status => 8,
        GlobalConstant::Client.mainnet_token_setup_property => 16,
        GlobalConstant::Client.mainnet_stake_and_mint_property => 32,
        GlobalConstant::Client.mainnet_ost_wallet_invited_users_property => 64,
        GlobalConstant::Client.mainnet_first_api_call_property => 128
    }
  end

  def self.sandox_statuses_config
    @c_s_statuses ||= {
        GlobalConstant::Client.sandbox_whitelisted_status => 1,
        GlobalConstant::Client.sandbox_whitelist_requested_status => 2,
        GlobalConstant::Client.sandbox_test_economy_qr_code_uploaded_status => 4,
        GlobalConstant::Client.sandbox_registered_in_mappy_server_status => 8,
        GlobalConstant::Client.webhook_registered_in_mappy_server_status => 16,
        GlobalConstant::Client.sandbox_token_setup_property => 32,
        GlobalConstant::Client.sandbox_stake_and_mint_property => 64,
        GlobalConstant::Client.sandbox_ost_wallet_invited_users_property => 128,
        GlobalConstant::Client.sandbox_first_api_call_property => 256
    }
  end

  def self.sandbox_client_mile_stones
    @c_s_m_stones ||= {
        GlobalConstant::Client.sandbox_registered_in_mappy_server_status => 1,
        GlobalConstant::Client.sandbox_token_setup_property => 1,
        GlobalConstant::Client.sandbox_stake_and_mint_property => 1,
        GlobalConstant::Client.sandbox_ost_wallet_invited_users_property => 1,
        GlobalConstant::Client.sandbox_first_api_call_property => 1
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        properties: properties_config,
        mainnet_statuses: mainnet_statuses_config,
        sandbox_statuses: sandox_statuses_config
    }
  end

  # Note : always include this after declaring bit_wise_columns_config method
  include BitWiseConcern

  after_commit :flush_cache

  # Format data to a format which goes into cache
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
        id: id,
        company_name: company_name.present? ? company_name : nil,
        properties: properties.present? ? Client.get_bits_set_for_properties(properties) : [],
        mainnet_statuses: mainnet_statuses.present? ? Client.get_bits_set_for_mainnet_statuses(mainnet_statuses) : [],
        sandbox_statuses: sandbox_statuses.present? ? Client.get_bits_set_for_sandbox_statuses(sandbox_statuses) : [],
        created_at: created_at.to_i
    }
  end

  # Flush caches
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::Client.new([id]).clear
  end

end
