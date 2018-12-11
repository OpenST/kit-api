# frozen_string_literal: true
module GlobalConstant

  class ClientManager

    class << self

      ### Privilages start ###

      def is_sandbox_admin_privilage
        'is_sandbox_admin'
      end

      def is_sandbox_super_admin_privilage
        'is_sandbox_owner'
      end

      def is_mainnet_admin_privilage
        'is_mainnet_admin'
      end

      def is_mainnet_super_admin_privilage
        'is_mainnet_owner'
      end

      ### Privilages stop ###

    end

  end

end
