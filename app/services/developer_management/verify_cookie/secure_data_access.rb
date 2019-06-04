module DeveloperManagement
  
  module VerifyCookie
  
    class SecureDataAccess < ServicesBase
    
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @params [String] sda_cookie_value (mandatory) - this is the secure data access cookie value
      # @params [Integer] manager_id (mandatory) - manager id
      # @params [String] action_name (optional) - action name
      #
      #
      # @return [DeveloperManagement::VerifyCookie::SecureDataAccess]
      #
      def initialize(params)
        super

        @sda_cookie_value = @params[:sda_cookie_value]
        @manager_id = @params[:manager_id]
        @action_name = @params[:action_name]

        @show_keys_enable_flag = 0
        @email_already_sent_flag = 0

        @failed_logs = {}
    
      end
    
      # Perform
      #
      # * Author: Puneet
      # * Date: 10/10/2017
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform
      
        handle_errors_and_exceptions do

          r = validate
          return r unless r.success?

          if @sda_cookie_value.present?

            return validation_error(
              's_dm_vc_sda_1',
              'invalid_api_params',
              ['missing_cookie_value'],
              GlobalConstant::ErrorAction.default
            ) unless Util::CommonValidator.is_string?(@sda_cookie_value)

            r = set_parts
            return r unless r.success?

            r = fetch_validation_hash_details
            return r unless r.success?

            r = validate_token
            return r unless r.success?

            check_cookie_status

          else

            if @action_name != 'developer_get'
              r = send_secure_data_access_link
              return r unless r.success?

              r = set_cookie_value
              return r unless r.success?

              success_with_data({
                                  cookie_value: @cookie_value,
                                  show_keys_enable_flag: @show_keys_enable_flag,
                                  email_already_sent_flag: @email_already_sent_flag
                                }, fetch_go_to)
            else
              #For developer page load when cookie was not present
              success_with_data({
                                  show_keys_enable_flag: @show_keys_enable_flag,
                                  email_already_sent_flag: @email_already_sent_flag
                                }, fetch_go_to)
            end

          end
      
        end
    
      end
    
      private
    
      # Set parts
      #
      # * Author: Dhananjay
      # * Date: 28/05/2019
      # * Reviewed By:
      #
      # Sets @manager_validation_hash_id, @cookie_creation_timestamp, @token
      #
      # @return [Result::Base]
      #
      def set_parts
        parts = @sda_cookie_value.split(':')

        return unauthorized_access_response('s_dm_vc_sda_2') unless parts.length == 3
      
        @manager_validation_hash_id = parts[0].to_i
        return unauthorized_access_response('s_dm_vc_sda_3') unless @manager_validation_hash_id > 0
      
        @cookie_creation_timestamp = parts[1].to_i
        return unauthorized_access_response('s_dm_vc_sda_4') unless @cookie_creation_timestamp + valid_upto >= current_timestamp
      
        @token = parts[2]
      
        success
      end
    
      # fetch validation hash details
      #
      # * Author: Dhananjay
      # * Date: 28/05/2019
      # * Reviewed By:
      #
      # @Sets @manager_validation_hash_rsp
      #
      # @return [Result::Base]
      #
      def fetch_validation_hash_details
        @manager_validation_hash_rsp = CacheManagement::ManagerValidationHash.new([@manager_validation_hash_id]).fetch[@manager_validation_hash_id]

        return unauthorized_access_response('s_dm_vc_sda_5') unless @manager_validation_hash_rsp.present?
        return unauthorized_access_response('s_dm_vc_sda_6') unless @manager_validation_hash_rsp[:kind].present? && (GlobalConstant::ManagerValidationHash.secure_data_access_kind == manager_validation_hash_rsp[:kind])
        return unauthorized_access_response('s_dm_vc_sda_7') if @manager_validation_hash_rsp[:validation_hash].nil?
        return unauthorized_access_response('s_dm_vc_sda_8') if @manager_validation_hash_rsp[:extra_data][:salt].nil?
        return unauthorized_access_response('s_dm_vc_sda_9') if @manager_validation_hash_rsp[:created_at].nil?
        return unauthorized_access_response('s_dm_vc_sda_10') if @manager_validation_hash_rsp[:status].nil?

        success
      end
    
      # Validate secure data access token
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_token
      
        evaluated_token = ManagerValidationHash.get_sda_cookie_token(
          manager_validation_hash_id: @manager_validation_hash_id,
          validation_hash: @manager_validation_hash_rsp[:validation_hash],
          salt: @manager_validation_hash_rsp[:extra_data][:salt],
          cookie_creation_time: @cookie_creation_timestamp
        )

        return unauthorized_access_response('s_dm_vc_sda_11') unless (evaluated_token == @token)
      
        success
    
      end
    
      # check cookie status
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def check_cookie_status

        @status = @manager_validation_hash_rsp[:status]

        # if cookie status is expired - create new
        if is_expired?(@cookie_creation_timestamp)

          r = send_secure_data_access_link
          return r unless r.success?

          r = set_cookie_value
          return r unless r.success?

          success_with_data({
                              cookie_value: @cookie_value,
                              show_keys_enable_flag: @show_keys_enable_flag,
                              email_already_sent_flag: @email_already_sent_flag
                            }, fetch_go_to)

          # if cookie status is NOT expired AND it is used - show keys
        elsif @status == GlobalConstant::ManagerValidationHash.used_status

          @show_keys_enable_flag = 1
          @email_already_sent_flag = 1

          success_with_data({
                              cookie_value: @sda_cookie_value,
                              show_keys_enable_flag: @show_keys_enable_flag,
                              email_already_sent_flag: @email_already_sent_flag
                            }, fetch_go_to)

          # email already has been send
        elsif @status != GlobalConstant::ManagerValidationHash.used_status

          @email_already_sent_flag = 1
          success_with_data({
                              cookie_value: @sda_cookie_value,
                              show_keys_enable_flag: @show_keys_enable_flag,
                              email_already_sent_flag: @email_already_sent_flag
                            }, fetch_go_to)

        end
    
      end

      # Generate and send secure data access verification token
      # send mail
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @Sets @manager_validation_hash_id, @email_already_sent_flag
      #
      def send_secure_data_access_link

        # NOTE:- we can not send mail from sidekiq thread,
        # because we need to fetch 'manager_validation_hash_id' from the response of this enqueue job.
        r = DeveloperManagement::SendSecureDataAccessLink.new(manager_id: @manager_id).perform
        return r unless r.success?

        @manager_validation_hash_id = r.data[:manager_validation_hash_id]

        @email_already_sent_flag = 1

        success
      end

      # set cookie
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_cookie_value

        manager_validation_hash_rsp = CacheManagement::ManagerValidationHash.new([@manager_validation_hash_id]).fetch[@manager_validation_hash_id]

        @cookie_value = ManagerValidationHash.get_sda_cookie_value(
          manager_validation_hash_id: @manager_validation_hash_id,
          validation_hash: manager_validation_hash_rsp[:validation_hash],
          salt: manager_validation_hash_rsp[:extra_data][:salt],
          c_at_timestamp: manager_validation_hash_rsp[:created_at].to_i #converted created_at date-time to timestamp
        )

        success
      end

      # fetch go to
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def fetch_go_to

        @go_to = GlobalConstant::GoTo.developer

      end
    
      # Unauthorized access response
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @param [String] err (mandatory) - err code
      #
      # @return [Result::Base]
      #
      def unauthorized_access_response(err)
        error_with_data(
          err,
          'unauthorized_access_response',
          GlobalConstant::ErrorAction.default
        )
      end

      # Valid upto
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      #
      def valid_upto
        
        GlobalConstant::Cookie.secure_data_access_cookie_expiry.to_i
      
      end

      # Expiry interval
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      #
      def expiry_interval

        GlobalConstant::ManagerValidationHash.secure_data_access_expiry_interval

      end

      # check if expired
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      #
      def is_expired?(created_at)
        (created_at.to_i + expiry_interval.to_i) < current_timestamp
      end

    end

  end
  
end