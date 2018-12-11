class ClientManager < EstablishCompanyClientDbConnection

  def self.mainnet_privilages_config
    @c_m_privilages ||= {
        GlobalConstant::ClientManager.is_mainnet_super_admin_privilage => 1,
        GlobalConstant::ClientManager.is_mainnet_admin_privilage => 2
    }
  end

  def self.sandbox_privilages_config
    @c_s_privilages ||= {
        GlobalConstant::ClientManager.is_sandbox_super_admin_privilage => 1,
        GlobalConstant::ClientManager.is_sandbox_admin_privilage => 2
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        mainnet_privilages: mainnet_privilages_config,
        sandbox_privilages: sandbox_privilages_config
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
  def formated_cache_data
    {
        client_id: client_id,
        manager_id: manager_id,
        mainnet_privilages: mainnet_privilages.present? ? ClientManager.get_bits_set_for_mainnet_privilages(mainnet_privilages) : [],
        sandbox_privilages: sandbox_privilages.present? ? ClientManager.get_bits_set_for_sandbox_privilages(sandbox_privilages) : []
    }
  end

  # Flush caches
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::ClientManager.new([manager_id], {client_id: client_id}).clear
  end

end
