# frozen_string_literal: true
module GlobalConstant

  class ManagerWhitelisting

    class << self

      ### Kind Start ###

      def reset_password_kind
        'reset_password'
      end

      def double_optin_kind
        'double_optin'
      end

      def manager_invite_kind
        'manager_invite'
      end

      ### Kind End ###

    end

  end

end
