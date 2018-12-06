module HookConcern

  extend ActiveSupport::Concern

  included do

    # Any model including this concern should have following columns in the table
    #
    # execution_timestamp (Decimal) : Time after which this hook should be processed
    # locked_at : Time when lock was acquired on this hook
    # status : status for this hook
    # failed_count : no. of times hook processing failed
    # success_response : serialized Hash containing success response
    # failed_response : serialized Hash containing last failure response

    # Also implement 2 methods
    # 1. batch_size_for_hooks_processor -> returning Integer mentioning batch size for one iteration of processor
    # 2. retry_limit_for_failed_hooks -> returning Integer mentioning retry count (for Failed Hooks)

    enum status: {
      pending_status => 1,
      processed_status => 2,
      failed_status => 3,
      ignored_status => 4,
      manually_interrupted_status => 5,
      manually_handled_status => 6
    }

    scope :unlocked_hooks, -> {
      where('lock_identifier IS NULL')
    }

    scope :pending_hooks_to_be_executed, -> {
      where('execution_timestamp < ?', Time.now.to_i).
        where(status: pending_status).
        limit(batch_size_for_hooks_processor)
    }

    scope :failed_hooks_to_be_retried, -> {
      where('failed_count <= ?', retry_limit_for_failed_hooks).
        where(status: failed_status).
        limit(batch_size_for_hooks_processor)
    }

    scope :lock_fresh_hooks, ->(lock_identifier) {
      unlocked_hooks.pending_hooks_to_be_executed.
        update_all(lock_identifier: lock_identifier, locked_at: Time.now.to_i)
    }

    scope :lock_failed_hooks, ->(lock_identifier) {
      unlocked_hooks.failed_hooks_to_be_retried.
        update_all(lock_identifier: lock_identifier, locked_at: Time.now.to_i)
    }

    scope :lock_hooks, ->(hook_ids, lock_identifier) {
      where(id: hook_ids).unlocked_hooks.pending_hooks_to_be_executed.
        update_all(lock_identifier: lock_identifier, locked_at: Time.now.to_i)
    }

    scope :fetch_locked_hooks, ->(lock_identifier) {
      where(lock_identifier: lock_identifier)
    }

    # Mark Hook as Processed
    #
    # * Author: Puneet
    # * Date: 11/10/2017
    # * Reviewed By: Sunil
    #
    # @param [Hash] sucess_log - log to be written in success response column
    #
    def mark_processed(sucess_log)
      update_attributes!(
        lock_identifier: nil,
        locked_at: nil,
        success_response: sucess_log,
        status: self.class.processed_status
      )
    end

    # Mark Hook as Failed Which would have to be retried Later
    #
    # * Author: Puneet
    # * Date: 11/10/2017
    # * Reviewed By: Sunil
    #
    # @param [Hash] failed_log - log to be written in failed response column
    #
    def mark_failed_to_be_retried(failed_log)
      update_attributes!(
        status: self.class.failed_status ,
        failed_count: failed_count + 1,
        lock_identifier: nil,
        locked_at: nil,
        failed_response: failed_log
      )
    end

    # Mark Hook as Failed Which wouldn't be retried later
    #
    # * Author: Puneet
    # * Date: 11/10/2017
    # * Reviewed By: Sunil
    #
    # @param [Hash] failed_log - log to be written in failed response column
    #
    def mark_failed_to_be_ignored(failed_log)
      update_attributes!(
        status: self.class.ignored_status ,
        failed_count: failed_count + 1,
        lock_identifier: nil,
        locked_at: nil,
        failed_response: failed_log
      )
    end

  end

  class_methods do

    ############ Stauses #############

    def pending_status
      'pending'
    end

    def processed_status
      'processed'
    end

    def failed_status
      'failed'
    end

    def ignored_status
      'ignored'
    end

    def manually_interrupted_status
      'manually_interrupted'
    end

    def manually_handled_status
      'manually_handled'
    end

  end

end