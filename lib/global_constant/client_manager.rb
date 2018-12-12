# frozen_string_literal: true
module GlobalConstant

  class ClientManager

    class << self

      ### Privilages start ###

      def is_admin_privilage
        'is_admin'
      end

      def is_super_admin_privilage
        'is_super_admin'
      end

      def is_invited_privilage
        'is_invited'
      end

      def has_rejected_invite_privilage
        'has_rejected_invite'
      end

      ### Privilages stop ###

    end

  end

end
