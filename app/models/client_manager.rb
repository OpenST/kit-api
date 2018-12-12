class ClientManager < EstablishKitClientDbConnection

  def self.privilages_config
    @c_privilages ||= {
        GlobalConstant::ClientManager.is_super_admin_privilage => 1,
        GlobalConstant::ClientManager.is_admin_privilage => 2,
        GlobalConstant::ClientManager.is_invited_privilage => 4,
        GlobalConstant::ClientManager.has_rejected_invite_privilage => 8,
        GlobalConstant::ClientManager.has_been_deleted_privilage => 16
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        privilages: privilages_config
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
        privilages: privilages.present? ? ClientManager.get_bits_set_for_privilages(privilages) : []
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
