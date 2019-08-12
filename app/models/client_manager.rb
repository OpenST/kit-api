class ClientManager < DbConnection::KitClient

  def self.privileges_config
    @c_privileges ||= {
        GlobalConstant::ClientManager.is_super_admin_privilege => 1,
        GlobalConstant::ClientManager.is_admin_privilege => 2,
        GlobalConstant::ClientManager.is_admin_invited_privilege => 4,
        GlobalConstant::ClientManager.has_rejected_invite_privilege => 8,
        GlobalConstant::ClientManager.has_been_deleted_privilege => 16,
        GlobalConstant::ClientManager.is_super_admin_invited_privilege => 32
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
        'client_id = ? AND privileges & ? > 0',
        client_id,
        ClientManager.privileges_config[GlobalConstant::ClientManager.is_super_admin_privilege]
    )
  }

  # 4 represents the number of bits to the right of deleted user privilege
  scope :admins, ->(client_id) {
    where(
        'client_id = ? AND (privileges & ? > 0 OR privileges & ? > 0) AND (privileges & 16 = 0)',
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

  # Atomically update client manager properties
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.atomic_update_bitwise_columns(client_id, manager_id set_props_array, unset_props_array)

    throw 'client id or manager id is not sent' unless (client_id.present? && manager_id.present?)

    throw 'common properties for set and unset.' if (set_props_array & unset_props_array).present?

    clubbed_set_properties = {}
    clubbed_unset_properties = {}

    set_props_array.each do |property|
      column_name, value = ClientManager.send("get_bit_details_for_#{property}")

      if clubbed_set_properties[column_name].present?
        clubbed_set_properties[column_name] |= value
      else
        clubbed_set_properties[column_name] = value
      end
    end

    unset_props_array.each do |property|
      column_name, value = ClientManager.send("get_bit_details_for_#{property}")

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
      reverse_value = ~value
      update_strings.push("#{column_name} = #{column_name} & #{reverse_value}")
    end

    update_string = update_strings.join(',')

    ClientManager.where(client_id: client_id, manager_id: manager_id).update_all([update_string])

    ClientManager.deliberate_cache_flush(client_id, manager_id)
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

  # Flush caches
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.deliberate_cache_flush(client_id, manager_id)
    CacheManagement::ClientManager.new([manager_id], {client_id: client_id}).clear
  end

end
