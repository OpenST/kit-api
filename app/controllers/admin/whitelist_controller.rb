class Admin::WhitelistController < Admin::BaseController

  # Whitelist domain or email
  #
  # * Author: Shlok
  # * Date: 11/12/2018
  # * Reviewed By:
  #
  def whitelist_domain_or_email
    if params.has_key?(:email)
      whitelist_email
    elsif params.has_key?(:email_domain)
      whitelist_domain
    end
  end

  # Whitelist domain
  #
  # * Author: Shlok
  # * Date: 14/09/2018
  # * Reviewed By:
  #
  def whitelist_domain
    service_response = AdminManagement::Whitelist::Domain.new(params).perform
    render_api_response(service_response)
  end

  # Whitelist email
  #
  # * Author: Shlok
  # * Date: 14/09/2018
  # * Reviewed By:
  #
  def whitelist_email
    service_response = AdminManagement::Whitelist::Email.new(params).perform
    render_api_response(service_response)
  end

end
