# frozen_string_literal: true
module GlobalConstant

  module Aws

    class Kms

      class << self

        def get_key_id_for(purpose)
          GlobalConstant::Base.kms[purpose]['id']
        end

        def get_key_arn_for(purpose)
          GlobalConstant::Base.kms[purpose]['arn']
        end

      end

    end

  end

end