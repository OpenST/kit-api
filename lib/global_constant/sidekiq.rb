# frozen_string_literal: true
module GlobalConstant

  class Sidekiq

    class << self

      # Queue config
      #
      # * Author: Bala
      # * Date: 11/10/2017
      # * Reviewed By:
      #
      # The following key value pairs are grouped by values using the following logic:
      # all sk_api_med_* values are considered as one. all sk_api_high_* are considered as one.
      # all sk_api_high_* has more priority than sk_api_med_*
      # with in a group, the key in the following hash which comes first gets higher priority.
      #
      # @return [Hash]
      #
      def queues_config
        @queues_config ||= {
          default_high_priority_queue: :sk_api_high_task,
          default_medium_priority_queue: :sk_api_med_task,
          default_low_priority_queue: :sk_api_default
        }
      end

      def queue_name(name)
        queues_config[name]
      end

      def queue_names
        queues_config
      end

    end

    private_class_method :queues_config

  end

end
