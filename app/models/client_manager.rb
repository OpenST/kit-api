class ClientManager < DbConnection::KitClient

  def self.privileges_config
    @c_privileges ||= {
        GlobalConstant::ClientManager.is_super_admin_privilege => 1,
        GlobalConstant::ClientManager.is_admin_privilege => 2,
        GlobalConstant::ClientManager.is_admin_invited_privilege => 4,
        GlobalConstant::ClientManager.has_rejected_invite_privilege => 8,
        GlobalConstant::ClientManager.has_been_deleted_privilege => 16,
        GlobalConstant::ClientManager.is_super_admin_invited_privilege => 32,
        # Use the constants from client for admin level replications
        GlobalConstant::Client.token_setup_property => 64,
        GlobalConstant::Client.stake_and_mint_property => 128,
        GlobalConstant::Client.ost_wallet_setup_property => 256,
        GlobalConstant::Client.ost_wallet_invited_users_property => 512,
        GlobalConstant::Client.first_api_call_property => 1024
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        privileges: privileges_config
    }
  end

  # Note : always include this after declaring bit_wise_columns_config method
  include BitWiseConcern

  after_commit :flush_cache

  scope :super_admins, ->(client_id) {
    where(
        'client_id = ? AND privileges | ? > 0',
        client_id,
        ClientManager.privileges_config[GlobalConstant::ClientManager.is_super_admin_privilege]
    )
  }

  scope :admins, ->(client_id) {
    where(
        'client_id = ? AND (privileges | ? > 0 OR privileges | ? > 0)',
        client_id,
        ClientManager.privileges_config[GlobalConstant::ClientManager.is_super_admin_privilege],
        ClientManager.privileges_config[GlobalConstant::ClientManager.is_admin_privilege]
    )
  }

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
      client_id: client_id,
      manager_id: manager_id,
      privileges: privileges.present? ? ClientManager.get_bits_set_for_privileges(privileges) : []
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
