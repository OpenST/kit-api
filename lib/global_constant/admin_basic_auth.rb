# frozen_string_literal: true
module GlobalConstant

  class AdminBasicAuth < GlobalConstant::Base

    class << self

      def username
        config['username']
      end

      def password
        config['password']
      end

      private

      def config
        GlobalConstant::Base.admin_basic_auth_config
      end

    end

  end

end
