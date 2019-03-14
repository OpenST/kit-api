module Email

  module HookProcessor

    class Base

      include Util::ResultHelper

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::Base] returns an object of Email::HookProcessor::Base class
      #
      def initialize(hook)
        @hook = hook
        @manager_id = nil
        @email = nil
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def perform

        r = validate
        return r unless r.success?

        r = set_email
        return r unless r.success?

        process_hook

      end

      private

      # sub classes to implement logic of validating here
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate
        fail 'sub class to implement'
      end

      # sub classes to implement logic of processing hook here
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook
        fail 'sub class to implement'
      end

      # builds params which go into API call to Email Service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Array]
      #
      def add_update_contact_params
        [
          GlobalConstant::PepoCampaigns.master_list_id,
          @email,
          attributes_hash,
          user_settings_hash
        ]
      end

      # Build attributes for email service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def attributes_hash
        fail 'sub class to implement'
      end

      # Build user settings for email service
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Hash]
      #
      def user_settings_hash
        fail 'sub class to implement'
      end

      # Fetch email from managers table
      #
      # * Author: Dhananjay
      # * Date: 11/03/2019
      # * Reviewed By:
      #
      # @Sets @email
      #
      # @return [Result::Base]
      #
      def set_email
        
        if @hook[:receiver_entity_kind] == GlobalConstant::EmailServiceApiCallHook.support_receiver_entity_kind
          @email = GlobalConstant::Base.support_email
        else
          r = set_manager_id
          return r unless r.success?
  
          manager_data = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
  
          @email = manager_data[:email]
        end
        
        success

      end

      # Select manager id based on receiver entity kind
      #
      # * Author: Dhananjay
      # * Date: 11/03/2019
      # * Reviewed By:
      #
      # @Sets @manager_id
      #
      # @return [Result::Base]
      #
      def set_manager_id
        
        receiver_entity_kind = @hook[:receiver_entity_kind]
        receiver_entity_id = @hook[:receiver_entity_id]
        
        if receiver_entity_kind == GlobalConstant::EmailServiceApiCallHook.client_receiver_entity_kind

          #TODO: Can we cache this query ?
          client_info = ClientManager.where(
              'client_id = ? AND privileges & ? > 0',
              receiver_entity_id, ClientManager.privileges_config[GlobalConstant::ClientManager.is_super_admin_privilege]).first

          @manager_id = client_info.manager_id

        elsif receiver_entity_kind == GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind
          @manager_id =  receiver_entity_id
        end

        success

      end

    end

  end

end