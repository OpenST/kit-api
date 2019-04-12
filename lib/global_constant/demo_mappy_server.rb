# frozen_string_literal: true
module GlobalConstant

  class DemoMappyServer

    def self.api_endpoint
      GlobalConstant::Base.demo_mappy_server[:endpoint]
    end

  end

end