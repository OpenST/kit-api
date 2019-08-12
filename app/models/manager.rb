class Manager < DbConnection::KitClient

  enum status: {
      GlobalConstant::Manager.invited_status => 1,
      GlobalConstant::Manager.active_status => 2,
      GlobalConstant::Manager.auto_blocked_status => 3
  }

  after_commit :flush_cache

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
  def formatted_cache_data
    {
        id: id,
        first_name: first_name,
        last_name: last_name,
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
  def formatted_secure_cache_data
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
  def is_eligible_for_reset_password?
    [
        GlobalConstant::Manager.active_status,
        GlobalConstant::Manager.auto_blocked_status
    ].include?(status)
  end


  # Atomically update manager bitwise columns
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.atomic_update_bitwise_columns(manager_id, set_props_array, unset_props_array)

    clubbed_set_properties = {}
    clubbed_unset_properties = {}

    set_props_array.each do |property|
      column_name, value = Manager.send("get_bit_details_for_#{property}")

      if clubbed_set_properties[column_name].present?
        clubbed_set_properties[column_name] |= value
      else
        clubbed_set_properties[column_name] = value
      end
    end

    unset_props_array.each do |property|
      column_name, value = Manager.send("get_bit_details_for_#{property}")

      if clubbed_unset_properties[column_name].present?
        clubbed_unset_properties[column_name] |= value
      else
        clubbed_unset_properties[column_name] = value
      end
    end

    update_strings = []

    # Set property update strings
    clubbed_set_properties.each do |column_name, value|
      update_strings.push("#{column_name} = #{column_name} | #{value}")
    end

    # Unset property update strings
    clubbed_set_properties.each do |column_name, value|
      update_strings.push("#{column_name} = #{column_name} ^ #{value}")
    end

    update_string = update_strings.join(',')

    Manager.where(id: manager_id).update_all([update_string])

    Manager.deliberate_cache_flush(manager_id)
  end

  # Flush caches
  #
  # * Author: Puneet
  # * Date: 01/02/2018
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::Manager.new([id]).clear
    CacheManagement::ManagerSecure.new([id]).clear
  end

  # Flush caches
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.deliberate_cache_flush(id)
    CacheManagement::Manager.new([id]).clear
    CacheManagement::ManagerSecure.new([id]).clear
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
    return "#{params[:manager_id]}:#{cookie_creation_time}:#{params[:auth_level]}:#{params[:manager_device_id]}:#{token_e}"
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
    string_to_sign = "#{params[:manager_id]}:#{params[:token_s]}:#{params[:last_session_updated_at]}:#{params[:browser_user_agent]}:#{params[:cookie_creation_time]}:#{params[:auth_level]}"
    key="#{params[:manager_id]}:#{params[:cookie_creation_time]}:#{params[:last_session_updated_at]}:#{params[:browser_user_agent]}:#{params[:manager_device_id]}:#{params[:fingerprint]}:#{params[:token_s][-12..-1]}:#{GlobalConstant::SecretEncryptor.cookie_key}"
    OpenSSL::HMAC.hexdigest("SHA256", key, string_to_sign)
  end

end
