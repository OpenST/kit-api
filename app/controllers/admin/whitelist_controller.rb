class Admin::WhitelistController < Admin::BaseController
  
  # Whitelist domain
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  def domain
    service_response = AdminManagement::Whitelist::Domain.new(params).perform
    render_api_response(service_response)
  end

  # Whitelist email
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  def email
    service_response = AdminManagement::Whitelist::Email.new(params).perform
    render_api_response(service_response)
  end

end
