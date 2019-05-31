module DeveloperManagement
  
  module VerifyCookie
  
    class SecureDataAccess < ServicesBase
    
      # Initialize
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @params [String] sda_cookie_value (mandatory) - this is the admin cookie value
      #
      # @return [DeveloperManagement::VerifyCookie::SecureDataAccess]
      #
      def initialize(params)
        super

        @sda_cookie_value = @params[:sda_cookie_value]
        @manager = @params[:manager]
        @action_name = @params[:action_name]

        @show_keys_enable_flag = 0

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

            @sda_cookie_value = @sda_cookie_value.to_s

            r = set_parts
            return r unless r.success?

            r = fetch_validation_hash_details
            return r unless r.success?

            r = validate_token
            return r unless r.success?

            check_status

          else

            if @action_name != 'developer_get'
              r = send_secure_data_access_link
              return r unless r.success?

              r = fetch_validation_hash_details
              return r unless r.success?

              set_cookie_value

              notify_devs

              success_with_data({ cookie_value: @cookie_value, show_keys_enable_flag: @show_keys_enable_flag }, fetch_go_to)
            else
              success_with_data({ show_keys_enable_flag: @show_keys_enable_flag }, fetch_go_to)
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
      # Sets @manager_validation_hash_id, @created_ts, @token
      #
      # @return [Result::Base]
      #
      def set_parts
        parts = @sda_cookie_value.split(':')

        return unauthorized_access_response('s_dm_vc_sda_2') unless parts.length == 3
      
        @manager_validation_hash_id = parts[0].to_i
        return unauthorized_access_response('s_dm_vc_sda_3') unless @manager_validation_hash_id > 0
      
        @created_ts = parts[1].to_i
        return unauthorized_access_response('s_dm_vc_sda_4') unless @created_ts + valid_upto >= current_timestamp
      
        @token = parts[2]
      
        success
      end
    
      # fetch validation hash details
      #
      # * Author: Dhananjay
      # * Date: 28/05/2019
      # * Reviewed By:
      #
      # @sets @validation_hash, @salt, @created_at_timestamp, @kind, @status
      #
      # @return [Result::Base]
      #
      def fetch_validation_hash_details
        manager_validation_hash_rsp = CacheManagement::ManagerValidationHash.new([@manager_validation_hash_id]).fetch[@manager_validation_hash_id]

        return unauthorized_access_response('s_dm_vc_sda_5') unless manager_validation_hash_rsp.present?
        return unauthorized_access_response('s_dm_vc_sda_6') unless manager_validation_hash_rsp[:kind].present? && (GlobalConstant::ManagerValidationHash.secure_data_access_kind == manager_validation_hash_rsp[:kind])
        return unauthorized_access_response('s_dm_vc_sda_7') if manager_validation_hash_rsp[:validation_hash].nil?
        return unauthorized_access_response('s_dm_vc_sda_8') if manager_validation_hash_rsp[:extra_data][:salt].nil?
        return unauthorized_access_response('s_dm_vc_sda_9') if manager_validation_hash_rsp[:created_at].nil?
        return unauthorized_access_response('s_dm_vc_sda_10') if manager_validation_hash_rsp[:status].nil?

        @kind = manager_validation_hash_rsp[:kind]
        @validation_hash = manager_validation_hash_rsp[:validation_hash]
        @salt = manager_validation_hash_rsp[:extra_data][:salt]
        @created_at_timestamp = manager_validation_hash_rsp[:created_at].to_time.to_i #converted created_at date-time to timestamp
        @status = manager_validation_hash_rsp[:status]

        success
      end
    
      # Validate token
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_token
      
        evaluated_token = ManagerValidationHash.get_cookie_token(
          manager_validation_hash_id: @manager_validation_hash_id,
          validation_hash: @validation_hash,
          salt: @salt,
          cookie_creation_time: @created_ts,
          c_at_timestamp: @created_at_timestamp
        )
      
        return unauthorized_access_response('s_dm_vc_sda_11') unless (evaluated_token == @token)
      
        success
    
      end
    
      # check status
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def check_status

        # if cookie status is expired
        if is_expired?(@created_at_timestamp)

          r = send_secure_data_access_link
          return r unless r.success?

          set_cookie_value

          notify_devs

          success_with_data({cookie_value: @cookie_value, show_keys_enable_flag: @show_keys_enable_flag}, fetch_go_to)

          # if cookie status is NOT expired AND it is used
        elsif @status == GlobalConstant::ManagerValidationHash.used_status
          # show keys

          @show_keys_enable_flag = 1
          success_with_data({cookie_value: @sda_cookie_value, show_keys_enable_flag: @show_keys_enable_flag}, fetch_go_to)

        elsif @status != GlobalConstant::ManagerValidationHash.used_status
          # email already has been send

          return error_with_go_to('s_dm_vc_sda_12', 'email_already_has_been_sent', fetch_go_to)

        end
    
      end

      # Generate and send secure data access verification token
      # send mail
      #
      # * Author: Dhananjay
      # * Date: 01/06/2019
      # * Reviewed By:
      #
      # @sets @manager_validation_hash_id
      #
      def send_secure_data_access_link
        # NOTE:- we can not send mail from sidekiq thread,
        # because we need to fetch 'manager_validation_hash_id' from the response of this enqueue job.
        r = DeveloperManagement::SendSecureDataAccessLink.new(manager_id: @manager[:id]).perform
        @failed_logs[:send_device_verification_link] = r.to_hash unless r.success?

        @manager_validation_hash_id = r.data[:manager_validation_hash_id]

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

        @cookie_value = ManagerValidationHash.get_cookie_value(
          manager_validation_hash_id: @manager_validation_hash_id,
          validation_hash: @validation_hash,
          salt: @salt,
          c_at_timestamp: @created_at_timestamp
        )

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
        
        GlobalConstant::Cookie.secure_data_access_cookie_expiry
      
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
        (created_at.to_i + expiry_interval.to_i) < Time.now.to_i
      end

      # Send mail
      #
      # * Author: Puneet
      # * Date: 09/12/2018
      # * Reviewed By:
      #
      def notify_devs
        ApplicationMailer.notify(
          data: @failed_logs,
          body: {manager_id: @manager[:id]},
          subject: 'Exception in InviteJob'
        ).deliver if @failed_logs.present?
      end
      
  
    end

  end
  
end