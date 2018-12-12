module ManagerManagement

  class ListAdmins < ServicesBase

    # Initialize
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Integer] page_no (optional) - Page no.
    #
    # @return [ManagerManagement::ListAdmins]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @page_no =  @params[:page_no] || 1

      @page_size = 10

      @api_response_data = {}
      @api_response_data[:meta] = {}
      @api_response_data[:meta][:nextPagePayload] = {}
      @api_response_data[:result_type] = 'client_admins'

    end

    # Perform
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

      validate_and_sanitize

      fetch_admins

      fetch_admin_email_ids

      success_with_data(@api_response_data)

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validate

      validate_page_no

      success

    end

    def validate_page_no

      fail OstCustomError.new validation_error(
                                'mm_su_i_1',
                                'invalid_api_params',
                                'invalid_page_no',
                                GlobalConstant::ErrorAction.default
                              ) unless Util::CommonValidator.is_numeric?(@page_no)

      @page_no = @page_no.to_i # Convert to integer if string is passed.

    end

    # Fetch client manager details
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_admins

      offset_value = (@page_no - 1) * @page_size

      client_managers_data = ClientManager.where(
        'client_id = ? AND privilages & ? = 0',
        @client_id, ClientManager.privilages_config[GlobalConstant::ClientManager.has_been_deleted_privilage]).
        limit(@page_size + 1). # Fetch one more to check whether more entries are there or not.
        offset(offset_value)

      # Fetch all client ids.
      @client_ids = client_managers_data.select(:manager_id).all.collect(&:manager_id)

      # Fetch all client info.
      client_info = client_managers_data.to_a

      # Format the managers info
      client_managers_info = []
      client_info.each do |client_manager|
        client_manager = client_manager.formated_cache_data
        client_managers_info.push(client_manager)
      end

      # If more entries are still available, populate nextPagePayload in response.
      if @client_ids.length > @page_size
        @api_response_data[:meta][:nextPagePayload][:page_size] = @page_size
        @api_response_data[:meta][:nextPagePayload][:page_no] = @page_no + 1
        client_managers_info = client_managers_info.first(@page_size)
      end

      @api_response_data[:client_admins] = client_managers_info

    end

    # Fetch manager details
    #
    # * Author: Shlok
    # * Date: 12/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_admin_email_ids

      managers_data = CacheManagement::Manager.new(@client_ids).fetch

      @api_response_data[:managers] = managers_data

    end

  end

end