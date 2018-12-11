class Admin::WhitelistController < Admin::BaseController
  
  # Whitelist domain
  #
  # * Author: Dhananjay
  # * Date: 14/09/2018
  # * Reviewed By: Sunil Khedar
  #
  def whitelist_domain
    render_api_response(service_response)
  end

  # Whitelist email
  #
  # * Author: Dhananjay
  # * Date: 14/09/2018
  # * Reviewed By: Sunil Khedar
  #
  def whitelist_email
    render_api_response(service_response)
  end

end
