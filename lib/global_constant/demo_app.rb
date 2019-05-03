# frozen_string_literal: true
module GlobalConstant

  class DemoApp

    def self.android_url
      config[:android_url]
    end

    def self.ios_url
      config[:ios_url]
    end

    private

    def self.config
      @config ||= GlobalConstant::Base.demo_app
    end

  end

end