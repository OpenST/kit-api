module Crons

  module HookProcessors

    class EmailServiceApiCall < Crons::HookProcessors::Base

      # initialize
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      # @param [Boolean] process_failed (optional) : flag which says that we have to only processed failed events
      #
      # @return [Crons::HooksProcessor::EmailServiceApiCall]
      #
      def initialize(params)
        super
        @processor_klasses = {}
      end

      # public method to process hooks
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      def perform
        super
      end

      private

      # modal klass which has data about hooks
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      # @return [Class] : returns a class
      #
      def hook_model_klass
        @m_k ||= EmailServiceApiCallHook
      end

      # process hook
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      # @Sets @success_responses, @failed_hook_to_be_ignored & @failed_hook_to_be_retried
      #
      def process_hook

        klass = get_hook_processor_klass
        response = klass.new(@hook).perform
        if response.success?
          @success_responses[@hook.id] = response.data
        else
          response_data = response.data

          # email sending failed due to hard bounce or soft bounce, we mark the hook as to_be_ignored and not to_be_retried.
          if response_data['error'] == 'VALIDATION_ERROR' &&
              response_data['error_message'].present? &&
              response_data['error_message'].is_a?(Hash) &&
              response_data['error_message']['subscription_status'].present?
            @failed_hook_to_be_ignored[@hook.id] = response_data
          else
            @failed_hook_to_be_retried[@hook.id] = response_data
          end

        end

      end

      # depending on event type returns approriate processor klass
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      # @return [Object] one of the Klasses in Email::HookCreator folder
      #
      def get_hook_processor_klass
        @processor_klasses[@hook.event_type] ||= begin
          case @hook.event_type
            when GlobalConstant::EmailServiceApiCallHook.add_contact_event_type
              klass = Email::HookProcessor::AddContact
            when GlobalConstant::EmailServiceApiCallHook.update_contact_event_type
              klass = Email::HookProcessor::UpdateContact
            when GlobalConstant::EmailServiceApiCallHook.send_transactional_mail_event_type
              klass = Email::HookProcessor::SendTransactionalMail
            else
              raise "unhandled event_type: #{@hook.event_type}"
          end
          klass
        end
      end

      # after completion of batch, mark hooks as processed in EmailServiceApiCall DB
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      def update_status_to_processed
        @hooks_to_be_processed.each do |hook|
          response = @success_responses[hook.id]
          next if response.nil?
          hook.mark_processed(response)
        end
      end

      # notify devs if required
      #
      # * Author: Puneet
      # * Date: 11/11/2017
      # * Reviewed By:
      #
      def notify_devs
        ApplicationMailer.notify(
          body: {
            to_be_retried: @failed_hook_to_be_retried
          },
          data: {
            process_failed: @process_failed
          },
          subject: 'Errors in EmailServiceApiCall Hook Processor'
        ).deliver if @failed_hook_to_be_retried.present?
      end

    end

  end

end