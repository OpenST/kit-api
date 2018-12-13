module Util

  class CommonSanitizer

    class << self

      # hide some chars of email
      #
      # * Author: Puneet
      # * Date: 12/12/2018
      # * Reviewed By:
      #
      # @param [String] email
      #
      # @return [String]
      #
      def secure_email(email)
        email.gsub(/.{0,4}@/, '***@')
      end

    end

  end

end