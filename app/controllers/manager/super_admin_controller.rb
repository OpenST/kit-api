class Manager::SuperAdminController < Manager::BaseController

  before_action :verify_mfa_cookie

  before_action :verify_super_admin_role

  # Check if Super Admin role
  #
  # * Author: Puneet
  # * Date: 11/12/2018
  # * Reviewed By:
  #
  def verify_super_admin_role
    service_response = ManagerManagement::SuperAdmin::VerifySuperAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Reset MFA of admins
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By:
  #
  def reset_mfa
    service_response = ManagerManagement::SuperAdmin::ResetMfa.new(params).perform
    render_api_response(service_response)
  end

  # Invite new managers
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By:
  #
  def invite_admin
    service_response = ManagerManagement::SuperAdmin::InviteAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Delete admin
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By:
  #
  def delete_admin
    service_response = ManagerManagement::SuperAdmin::DeleteAdmin.new(params).perform
    render_api_response(service_response)
  end

end