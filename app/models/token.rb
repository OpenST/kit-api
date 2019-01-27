class Token < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::ClientToken.not_deployed => 1,
    GlobalConstant::ClientToken.deployment_started => 2,
    GlobalConstant::ClientToken.deployment_completed => 3,
    GlobalConstant::ClientToken.deployment_failed => 4
  }

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
        client_id: client_id,
        name: name,
        symbol: symbol,
        conversion_factor: conversion_factor.present? ? conversion_factor.to_s : conversion_factor, # should be string as it goes to FE
        decimal: decimal,
        status: status
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