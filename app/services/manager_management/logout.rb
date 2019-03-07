module ManagerManagement

  class Logout < ServicesBase

    # Initialize
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By: Sunil
    #
    # @params [Integer] manager_id (mandatory) - manager id
    #
    # @return [ManagerManagement::Logout]
    #
    def initialize(params)
      super

      @manager_id = @params[:manager_id]
    end

    # Perform
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By: Sunil
    #
    def perform

      handle_errors_and_exceptions do

        r = logout_manager
        return r unless r.success?

        success

      end

    end

    private

    # Logout user
    #
    # * Author: Aniket
    # * Date: 21/09/2018
    # * Reviewed By: Sunil
    #
    def logout_manager

      Manager.where(id: @manager_id).update_all(last_session_updated_at: current_timestamp)

      CacheManagement::ManagerSecure.new([@manager_id]).clear

      success

    end

  end

end
