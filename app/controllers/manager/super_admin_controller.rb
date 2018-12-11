class Manager::SuperAdminController < Manager::BaseController

  before_action :verify_mfa_cookie

  before_action :verify_super_admin_role



  private

  # Check if Super Admin role
  #
  # * Author: Puneet
  # * Date: 11/12/2018
  # * Reviewed By:
  #
  def verify_super_admin_role
    # implement validation
  end

end