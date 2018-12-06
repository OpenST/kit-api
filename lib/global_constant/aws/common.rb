# frozen_string_literal: true
module GlobalConstant

  module Aws

    class Common

      class << self

        def get_credentials_for(role)
          if role == 'user'
            user_access_credentials
          else
            fail 'invalid role'
          end
        end

        def region
          GlobalConstant::Base.aws['region']
        end

        private

        def user_access_credentials
          GlobalConstant::Base.aws['user']
        end

      end

    end

  end

end