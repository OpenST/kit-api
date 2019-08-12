class Token < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::ClientToken.not_deployed => 1,
    GlobalConstant::ClientToken.deployment_started => 2,
    GlobalConstant::ClientToken.deployment_completed => 3,
    GlobalConstant::ClientToken.deployment_failed => 4
  }

  def self.properties_config
    @t_props ||= {
      GlobalConstant::ClientToken.has_ost_managed_owner => 1
    }
  end

  def self.bit_wise_columns_config
    @b_w_c_c ||= {
      properties: properties_config,
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
        client_id: client_id,
        name: name,
        symbol: symbol,
        conversion_factor: conversion_factor.present? ? conversion_factor.to_s : conversion_factor, # should be string as it goes to FE
        decimal: decimal,
        status: status,
        stake_currency_id: stake_currency_id,
        properties: properties.present? ? Token.get_bits_set_for_properties(properties) : [],
    }
  end

  after_commit :flush_cache


  # Atomically update manager bitwise columns
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.atomic_update_bitwise_columns(client_id, set_props_array, unset_props_array)

    throw 'client id is not sent' unless client_id.present?

    throw 'common properties for set and unset.' if (set_props_array & unset_props_array).present?

    clubbed_set_properties = {}
    clubbed_unset_properties = {}

    set_props_array.each do |property|
      column_name, value = Token.send("get_bit_details_for_#{property}")

      if clubbed_set_properties[column_name].present?
        clubbed_set_properties[column_name] |= value
      else
        clubbed_set_properties[column_name] = value
      end
    end

    unset_props_array.each do |property|
      column_name, value = Token.send("get_bit_details_for_#{property}")

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

    Token.where(client_id: client_id).update_all([update_string])

    Token.deliberate_cache_flush(client_id)
  end

  # Flush caches
  #
  # * Author: Shlok
  # * Date: 22/01/2019
  # * Reviewed By:
  #
  def flush_cache
    KitSaasSharedCacheManagement::TokenDetails.new([client_id]).clear
  end

  # Flush caches
  #
  # * Author: Santhosh
  # * Date: 08/08/2019
  # * Reviewed By:
  #
  def self.deliberate_cache_flush(client_id)
    KitSaasSharedCacheManagement::TokenDetails.new([client_id]).clear
  end

end