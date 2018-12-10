class EmailServiceApiCallHook < EstablishKitAsyncHooksDbConnection

  enum event_type: {
      GlobalConstant::EmailServiceApiCallHook.add_contact_event_type => 1,
      GlobalConstant::EmailServiceApiCallHook.update_contact_event_type => 2,
      GlobalConstant::EmailServiceApiCallHook.send_transactional_mail_event_type => 3
  }

  serialize :params, Hash
  serialize :success_response, Hash
  serialize :failed_response, Hash

  class << self

    # limit for number of records to be processed in one iteration of continuis cron
    #
    # * Author: Puneet
    # * Date: 12/10/2017
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def batch_size_for_hooks_processor
      10
    end

    # retry count
    #
    # * Author: Puneet
    # * Date: 12/10/2017
    # * Reviewed By:
    #
    # @return [Integer]
    #
    def retry_limit_for_failed_hooks
      3
    end

  end

  # having it here as we need to methods (batch_size_for_hooks_processor & retry_limit_for_failed_hooks)
  # being set before this is called
  include HookConcern

end
