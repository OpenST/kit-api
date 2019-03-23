# frozen_string_literal: true
module GlobalConstant

  class EmailServiceApiCallHook

    class << self
  
      ########## receiver_entity_kinds #############
  
      def client_receiver_entity_kind
        'client'
      end
  
      def manager_receiver_entity_kind
        'manager'
      end
  
      def support_receiver_entity_kind
        'support'
      end
  
      ########## receiver_entity_kinds #############

      ########## event_types #############

      def add_contact_event_type
        'add_contact'
      end

      def update_contact_event_type
        'update_contact'
      end

      def send_transactional_mail_event_type
        'send_transactional_mail'
      end

      ########## entity_types #############
      
      

    end

  end

end
