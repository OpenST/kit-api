class EmailServiceApiCallHook < DbConnection::KitSaasBigSubenv

  enum receiver_entity_kind: {
    GlobalConstant::EmailServiceApiCallHook.client_receiver_entity_kind => 1,
    GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind => 2,
    GlobalConstant::EmailServiceApiCallHook.support_receiver_entity_kind => 3,
    GlobalConstant::EmailServiceApiCallHook.whitelisting_requester_kind => 4,
    GlobalConstant::EmailServiceApiCallHook.test_economy_invite_receiver_entity_kind => 5,
    GlobalConstant::EmailServiceApiCallHook.specific_email_receiver_entity_kind => 6,
    GlobalConstant::EmailServiceApiCallHook.client_all_super_admins_receiver_entity_kind => 7,
  }

  enum event_type: {
      GlobalConstant::EmailServiceApiCallHook.add_contact_event_type => 1,
      GlobalConstant::EmailServiceApiCallHook.update_contact_event_type => 2,
      GlobalConstant::EmailServiceApiCallHook.send_transactional_mail_event_type => 3,
      GlobalConstant::EmailServiceApiCallHook.client_mile_stone_event_type => 4,
      GlobalConstant::EmailServiceApiCallHook.remove_contact_event_type => 5
  }

  serialize :params, JSON
  serialize :success_response, JSON
  serialize :failed_response, JSON

  class << self

    # limit for number of records to be processed in one iteration of continuous cron
    #
    # * Author: Puneet
    # * Date: 06/12/2018
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
    # * Date: 06/12/2018
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
