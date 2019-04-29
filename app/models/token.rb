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
        properties: properties.present? ? Token.get_bits_set_for_properties(properties) : [],
    }
  end

  after_commit :flush_cache

# Flush caches
#
# * Author: Shlok
# * Date: 22/01/2019
# * Reviewed By:
#
  def flush_cache
    KitSaasSharedCacheManagement::TokenDetails.new([client_id]).clear
  end


end