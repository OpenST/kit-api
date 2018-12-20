class DbConnection::ConfigSubenv < ApplicationRecord

  self.abstract_class = true

  def self.config_key
    "config_#{GlobalConstant::Base.sub_environment_name}_#{Rails.env}"
  end

  def self.applicable_sub_environments
    [
      GlobalConstant::Environment.sandbox_sub_environment,
      GlobalConstant::Environment.main_sub_environment
    ]
  end

  self.establish_connection(config_key.to_sym)

end
