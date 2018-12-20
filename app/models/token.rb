class Token < DbConnection::KitSaasSubenv


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
        decimal: decimal
    }
  end

end