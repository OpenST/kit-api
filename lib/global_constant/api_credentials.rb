module GlobalConstant

  class ApiCredentials

    class << self

      # time till which old key would be valid
      def buffer_time_in_minutes
        24 * 60 # 1 day
      end
    end

  end

end