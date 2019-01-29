class Admin::WhitelistController < Admin::BaseController

  # Whitelist client
  #
  # * Author: Shlok
  # * Date: 14/09/2018
  # * Reviewed By:
  #
  def whitelist
    service_response = AdminManagement::Whitelist::Client.new(params).perform
    render_api_response(service_response)
  end

end
