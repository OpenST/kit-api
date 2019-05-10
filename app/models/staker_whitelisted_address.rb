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
  def formatted_cache_data
    {
      token_id: token_id,
      stakerAddress: staker_address,
      gatewayComposerAddress: gateway_composer_address,
      status: status,
    }
  end

  # Fetch all addresses for token ids passed.
  #
  # * Author: Shlok
  # * Date: /03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_all_addresses(params)
    @token_id = params[:token_id]

    @return_data = {}
    staker_whitelisted_addresses = StakerWhitelistedAddress.where(token_id: @token_id).all

    staker_whitelisted_addresses.each do |address_row|
      @return_data[address_row.token_id] ||= {}
      @return_data[address_row.token_id][:staker_address] = address_row.staker_address
      @return_data[address_row.token_id][:gateway_composer_address] = address_row.gateway_composer_address
      @return_data[address_row.token_id][:status] = address_row.status
    end
    success_with_data(@return_data)
  end

end