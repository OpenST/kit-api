class Manager::SuperAdminController < Manager::BaseController

  # Reset MFA of admins
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def reset_mfa
    service_response = ManagerManagement::SuperAdmin::ResetMfa.new(params).perform
    render_api_response(service_response)
  end

  # Invite new managers
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def invite_admin
    service_response = ManagerManagement::SuperAdmin::InviteAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Delete admin
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def delete_admin
    service_response = ManagerManagement::SuperAdmin::DeleteAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Update super admin role
  #
  # * Author: Puneet
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def update_super_admin_role
    service_response = ManagerManagement::SuperAdmin::UpdateSuperAdminRole.new(params).perform
    render_api_response(service_response)
  end

  # Resend admin invite
  #
  # * Author: Shlok
  # * Date: 10/01/2019
  # * Reviewed By: Sunil
  #
  def resend_admin_invite
    service_response = ManagerManagement::SuperAdmin::ResendAdminInvite.new(params).perform
    render_api_response(service_response)
  end

end