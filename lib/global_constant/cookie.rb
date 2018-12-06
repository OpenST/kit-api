# frozen_string_literal: true
module GlobalConstant

  class Cookie

    class << self

      def user_cookie_name
        'ost_kit_ca'
      end

      def user_expiry
        300.minutes
      end

    end

  end

end
