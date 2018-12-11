class Manager::SuperAdminController < Manager::BaseController

  before_action :verify_mfa_cookie

  before_action :verify_super_admin_role



  private

  def verify_super_admin_role
    # implement validation
  end


end