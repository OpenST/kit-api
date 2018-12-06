class ClientManager < EstablishCompanyClientDbConnection

  def self.privilages_config
    @cm_privilages ||= {
        GlobalConstant::ClientManager.is_admin_privilage => 1,
        GlobalConstant::ClientManager.is_owner_privilage => 2
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        mainnet_privilages: privilages_config,
        sandbox_privilages: privilages_config
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
        client_id: client_id,
        manager_id: manager_id,
        mainnet_privilages: mainnet_privilages.present? ? Client.get_bits_set_for_mainnet_privilages(mainnet_privilages) : [],
        sandbox_privilages: sandbox_privilages.present? ? Client.get_bits_set_for_sandbox_privilages(sandbox_privilages) : []
    }
  end

end
