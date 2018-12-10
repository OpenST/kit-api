class Manager < EstablishCompanyClientDbConnection

  enum status: {
      GlobalConstant::Manager.invited_status => 1,
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
        current_client_id: current_client_id,
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
    {
      id: id,
      password: password,
      last_session_updated_at: last_session_updated_at,
      mfa_token: mfa_token
    }
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
  # * Reviewed By:
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
  # * Reviewed By:
  #
  # @return [String]
  #
  def self.get_cookie_value(params)
    cookie_creation_time = Time.now.to_i
    params[:cookie_creation_time] = cookie_creation_time
    token_e = self.get_cookie_token(params)
    return "#{params[:manager_id]}:#{cookie_creation_time}:#{params[:auth_level]}:#{token_e}"
  end

  # generate login cookie
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  # @return [String]
  #
  def self.get_cookie_token(params)
    puts "get_cookie_token_params: #{params}"
    string_to_sign = "#{params[:manager_id]}:#{params[:token_s]}:#{params[:last_session_updated_at]}:#{params[:browser_user_agent]}:#{params[:cookie_creation_time]}:#{params[:auth_level]}"
    key="#{params[:manager_id]}:#{params[:cookie_creation_time]}:#{params[:last_session_updated_at]}:#{params[:browser_user_agent]}:#{params[:token_s][-12..-1]}:#{GlobalConstant::SecretEncryptor.cookie_key}"
    OpenSSL::HMAC.hexdigest("SHA256", key, string_to_sign)
  end

end
