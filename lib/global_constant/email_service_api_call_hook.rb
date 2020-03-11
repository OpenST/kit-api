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

      def client_all_super_admins_receiver_entity_kind
        'client_all_super_admins_receiver_entity_kind'
      end

      def whitelisting_requester_kind
        'whitelisting_requester'
      end

      def test_economy_invite_receiver_entity_kind
        'test_economy_invite'
      end

      def specific_email_receiver_entity_kind
        'specific_email'
      end

      ########## receiver_entity_kinds #############

      ########## event_types #############

      def add_contact_event_type
        'add_contact'
      end

      def update_contact_event_type
        'update_contact'
      end

      def remove_contact_event_type
        'remove_contact'
      end

      def send_transactional_mail_event_type
        'send_transactional_mail'
      end

      def client_mile_stone_event_type
        'client_mile_stone'
      end

      ########## entity_types #############

    end

  end

end
