# frozen_string_literal: true
module GlobalConstant

  class ClientManager

    class << self

      ### Privileges start ###

      def is_admin_privilege
        'is_admin'
      end

      def is_super_admin_privilege
        'is_super_admin'
      end

      def is_invited_privilege
        'is_invited'
      end

      def has_rejected_invite_privilege
        'has_rejected_invite'
      end

      def has_been_deleted_privilege
        'has_been_deleted'
      end

      ### Privileges stop ###

    end

  end

end
