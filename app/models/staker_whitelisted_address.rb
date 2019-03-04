class StakerWhitelistedAddress < DbConnection::KitSaasSubenv

  include Util::ResultHelper

  enum status: {
    GlobalConstant::StakerWhitelistedAddress.active_status => 1,
    GlobalConstant::StakerWhitelistedAddress.inactive_status => 2,
  }

  # Format data to a format which goes into cache
  #
  # * Author: Shlok
  # * Date: /03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_cache_data
    {
      token_id: token_id,
      stakerAddress: staker_address,
      gatewayComposerAddress: gateway_composer_address
    }
  end

end