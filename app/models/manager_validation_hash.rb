class ManagerValidationHash < DbConnection::KitClient

  enum kind: {
      GlobalConstant::ManagerValidationHash.reset_password_kind => 1,
      GlobalConstant::ManagerValidationHash.double_optin_kind => 2,
      GlobalConstant::ManagerValidationHash.manager_invite_kind => 3,
      GlobalConstant::ManagerValidationHash.device_verification_kind => 4,
      GlobalConstant::ManagerValidationHash.secure_data_access_kind => 5
  }

  enum status: {
      GlobalConstant::ManagerValidationHash.active_status => 1,
      GlobalConstant::ManagerValidationHash.inactive_status => 2,
      GlobalConstant::ManagerValidationHash.used_status => 3
  }

  after_commit :flush_cache

  serialize :extra_data, Hash

  def self.token_delimitter
    return ':'
  end

  def is_expired?
    (self.created_at.to_i + expiry_interval.to_i) < Time.now.to_i
  end

  def expiry_interval
    case self.kind
    when GlobalConstant::ManagerValidationHash.double_optin_kind
      GlobalConstant::ManagerValidationHash.double_opt_in_expiry_interval
    when GlobalConstant::ManagerValidationHash.manager_invite_kind
      GlobalConstant::ManagerValidationHash.invite_in_expiry_interval
    when GlobalConstant::ManagerValidationHash.reset_password_kind
      GlobalConstant::ManagerValidationHash.reset_token_expiry_interval
    when GlobalConstant::ManagerValidationHash.device_verification_kind
      GlobalConstant::ManagerValidationHash.device_verification_expiry_interval
    when GlobalConstant::ManagerValidationHash.secure_data_access_kind
      GlobalConstant::ManagerValidationHash.secure_data_access_expiry_interval
    else
      fail "no expiry found for : #{self.kind}"
    end
  end

  # Format data to a format which goes into cache
  #
  # * Author: Dhananjay
  # * Date: 29/05/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
      id: id,
      manager_id: manager_id,
      client_id: client_id,
      validation_hash: validation_hash,
      kind: kind,
      status: status,
      extra_data: extra_data,
      created_at: created_at
    }
  end

  # Flush caches
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::ManagerValidationHash.new([id]).clear
  end

  # generate secure data access cookie
  #
  # * Author: Dhananjay
  # * Date: 29/05/2019
  # * Reviewed By:
  #
  # @return [String]
  #
  def self.get_cookie_value(params)
    cookie_creation_time = Time.now.to_i
    params[:cookie_creation_time] = cookie_creation_time
    token_e = self.get_cookie_token(params)
    return "#{params[:manager_validation_hash_id]}:#{cookie_creation_time}:#{token_e}"
  end

  # generate secure data access cookie
  #
  # * Author: Dhananjay
  # * Date: 29/05/2019
  # * Reviewed By:
  #
  # @return [String]
  #
  def self.get_cookie_token(params)
    string_to_sign = "#{params[:manager_validation_hash_id]}:#{params[:salt]}:#{params[:validation_hash]}:#{params[:cookie_creation_time]}:#{params[:c_at_timestamp]}"
    key="#{params[:manager_validation_hash_id]}:#{params[:cookie_creation_time]}:#{params[:validation_hash]}:#{params[:salt]}:#{params[:c_at_timestamp]}:#{GlobalConstant::SecretEncryptor.cookie_key}"
    OpenSSL::HMAC.hexdigest("SHA256", key, string_to_sign)
  end

end
