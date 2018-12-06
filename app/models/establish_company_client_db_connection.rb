class EstablishCompanyClientDbConnection < ApplicationRecord
  self.abstract_class = true

  def self.config_key
    "kit_client_#{Rails.env}"
  end

  def self.applicable_sub_environments
    [
        GlobalConstant::Environment.main_sub_environment,
        GlobalConstant::Environment.sandbox_sub_environment # TEMp change - remove this when deployment of both sandbox and main is done everytime.

    ]
  end

  self.establish_connection(config_key.to_sym)
end
