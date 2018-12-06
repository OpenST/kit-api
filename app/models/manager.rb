class Manager < EstablishCompanyManagerDbConnection

  enum status: {
      GlobalConstant::Manager.incomplete_status => 1,
      GlobalConstant::Manager.active_status => 2,
      GlobalConstant::Manager.auto_blocked_status => 3
  }

  def self.properties_config
    @m_props ||= {
        GlobalConstant::Manager.has_verified_email_property => 1,
        GlobalConstant::Manager.has_setup_mfa_property => 2
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
        properties: properties_config
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
        id: id,
        email: email,
        status: status,
        default_client_id: defaultClientId,
        properties: properties.present? ? Manager.get_bits_set_for_properties(properties) : []
    }
  end

  # Format data to a format which goes into cache
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_secure_cache_data
    {id: id, password: password}
  end

  # Can this user rest password ?
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [Boolean]
  #
  def is_eligible_for_reset_passowrd?
    [
        GlobalConstant::Manager.active_status,
        GlobalConstant::Manager.auto_blocked_status
    ].include?(status)
  end

  # Generate encrypted password
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By: Sunil
  #
  # @return [String]
  #
  def self.get_encrypted_password(password, salt)
    # sha256_params = {string: "#{password}::#{salt}", salt: salt[0..50]}

    begin
      OpenSSL::HMAC.hexdigest("SHA256", salt[0..50], "#{password}::#{salt}")
    rescue Encoding::CompatibilityError => e
      p = password.to_s.force_encoding("UTF-8")
      s = salt.to_s.force_encoding("UTF-8")
      OpenSSL::HMAC.hexdigest("SHA256", s[0..50], "#{p}::#{s}")
    end
  end

  # generate login cookie
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By: Sunil
  #
  # @return [String]
  #
  def self.get_cookie_value(user_id, default_client_id, password, browser_user_agent)
    current_ts = Time.now.to_i
    token_e = get_cookie_token(user_id, default_client_id, password, browser_user_agent, current_ts)
    "#{user_id}:#{default_client_id}:#{current_ts}:#{token_e}"
  end

  # generate login cookie token
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By: Sunil
  #
  # @return [String]
  #
  def self.get_cookie_token(user_id, client_id, password, browser_user_agent, current_ts)
    string_to_sign = "#{user_id}:#{password}:#{browser_user_agent}:#{current_ts}"
    key="#{user_id}:#{current_ts}:#{browser_user_agent}:#{password[-12..-1]}:#{GlobalConstant::SecretEncryptor.cookie_key}"
    OpenSSL::HMAC.hexdigest("SHA256", key, string_to_sign)
  end
  
end
