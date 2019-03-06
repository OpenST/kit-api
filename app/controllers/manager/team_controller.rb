class Manager::TeamController < Manager::BaseController

  before_action :verify_is_xhr , :except => [:get]

  # Get Manager's details to be shown on Team Page
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def get
    service_response = ManagerManagement::Team::Get.new(params).perform
    render_api_response(service_response)
  end

  # List Admins
  #
  # * Author: Puneet
  # * Date: 15/02/2018
  # * Reviewed By: Sunil
  #
  def list_admins
    service_response = ManagerManagement::Team::ListAdmins.new(params).perform
    render_api_response(service_response)
  end

  # Reset MFA of admins
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def reset_mfa
    service_response = ManagerManagement::Team::ResetMfa.new(params).perform
    render_api_response(service_response)
  end

  # Invite new managers
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def invite_admin
    service_response = ManagerManagement::Team::InviteAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Delete admin
  #
  # * Author: Shlok
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def delete_admin
    service_response = ManagerManagement::Team::DeleteAdmin.new(params).perform
    render_api_response(service_response)
  end

  # Update super admin role
  #
  # * Author: Puneet
  # * Date: 12/12/2018
  # * Reviewed By: Sunil
  #
  def update_super_admin_role
    service_response = ManagerManagement::Team::UpdateSuperAdminRole.new(params).perform
    render_api_response(service_response)
  end

  # Resend admin invite
  #
  # * Author: Shlok
  # * Date: 10/01/2019
  # * Reviewed By: Sunil
  #
  def resend_admin_invite
    service_response = ManagerManagement::Team::ResendAdminInvite.new(params).perform
    render_api_response(service_response)
  end

end