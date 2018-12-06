class Client < EstablishCompanyClientDbConnection

  enum status: {
      GlobalConstant::Client.active_status => 1,
      GlobalConstant::Client.inactive_status => 2
  }

  def self.properties_config
    @c_props ||= {
        GlobalConstant::Client.has_enforced_mfa_property => 1
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        properties: properties_config
    }
  end

  # Note : always include this after declaring bit_wise_columns_config method
  include BitWiseConcern

end
