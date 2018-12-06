class ClientManager < EstablishCompanyClientDbConnection

  def self.privilages_config
    @cm_privilages ||= {
        GlobalConstant::ClientManager.is_admin_privilage => 1,
        GlobalConstant::ClientManager.is_owner_privilage => 2
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        mainnetPrivilages: privilages_config,
        sandboxPrivilages: privilages_config
    }
  end

  # Note : always include this after declaring bit_wise_columns_config method
  include BitWiseConcern

end
