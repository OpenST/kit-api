class Client < EstablishCompanyClientDbConnection

  def self.properties_config
    @c_props ||= {
        GlobalConstant::Client.has_enforced_mfa_property => 1
    }
  end

  def self.mainnet_statuses_config
    @c_m_statuses ||= {
        GlobalConstant::Client.mainnet_active_status => 1,
        GlobalConstant::Client.mainnet_inactive_status => 2
    }
  end

  def self.sandox_statuses_config
    @c_s_statuses ||= {
        GlobalConstant::Client.sandbox_active_status => 1,
        GlobalConstant::Client.sandbox_inactive_status => 2
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

  # Format data to a format which goes into cache
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_cache_data
    {
        id: id,
        properties: properties.present? ? Client.get_bits_set_for_properties(properties) : [],
        mainnet_statuses: mainnet_statuses.present? ? Client.get_bits_set_for_mainnet_statuses(mainnet_statuses) : [],
        sandbox_statuses: sandbox_statuses.present? ? Client.get_bits_set_for_sandbox_statuses(sandbox_statuses) : []
    }
  end

end
