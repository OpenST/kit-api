class Manager::SuperAdminController < Manager::BaseController

  before_action :verify_super_admin_role

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

  # Update super admin role
  #
  # * Author: Puneet
  # * Date: 12/12/2018
  # * Reviewed By:
  #
  def update_super_admin_role
    service_response = ManagerManagement::SuperAdmin::UpdateSuperAdminRole.new(params).perform
    render_api_response(service_response)
  end

  # Resend admin invite
  #
  # * Author: Shlok
  # * Date: 10/01/2019
  # * Reviewed By:
  #
  def resend_admin_invite
    service_response = ManagerManagement::SuperAdmin::ResendAdminInvite.new(params).perform
    render_api_response(service_response)
  end

  private

  # Check if Super Admin role
  #
  # * Author: Puneet
  # * Date: 11/12/2018
  # * Reviewed By:
  #
  def verify_super_admin_role
    service_response = ManagerManagement::SuperAdmin::CheckSuperAdminRole.new(params).perform
    render_api_response(service_response) unless service_response.success?
  end

end