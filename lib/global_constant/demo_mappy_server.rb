# frozen_string_literal: true
module GlobalConstant

  class DemoMappyServer

    def self.api_endpoint
      GlobalConstant::Base.demo_mappy_server[:endpoint]
    end

    def self.mappy_secret_key
      @mappy_secret_key ||= ENV['KA_DEMO_MAPPY_SERVER_SECRET_KEY']
    end

  end

end