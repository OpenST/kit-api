class DbConnection::KitClient < ApplicationRecord
  self.abstract_class = true

  def self.config_key
    "kit_client_#{Rails.env}"
  end

  def self.applicable_sub_environments
    [
      GlobalConstant::Environment.sandbox_sub_environment
    ]
  end

  self.establish_connection(config_key.to_sym)
end
