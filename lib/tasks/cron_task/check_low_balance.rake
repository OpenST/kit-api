namespace :cron_task do

  namespace :check_low_balance do

    DEFAULT_RUNNING_INTERVAL = 1.hour

    # Check low balance of clients.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    desc "rake RAILS_ENV=development cron_task:check_low_balance:send_mail lock_key_suffix=1"
    desc "*/1 * * * * cd /mnt/kit-api/current && rake RAILS_ENV=staging cron_task:check_low_balance:send_mail lock_key_suffix=1 >> /mnt/kit-api/shared/log/send_mail.log"
    task :send_mail do |task|
      @sleep_interval = 2

      @process_name = "#{task}_#{ENV['lock_key_suffix']}"
      @performer_klass = 'LowBalanceEmail'
      @optional_params = {}
      execute_cron_task
    end

    private

    # Execute task.
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    task :execute_task => [:validate_params, :acquire_lock, :set_up_environment] do

      begin

        @iteration_count = 1
        @running_interval ||= DEFAULT_RUNNING_INTERVAL
        @sleep_interval ||= 1 # In Seconds

        register_signal_handlers

        Token.find_in_batches(batch_size: 15) do |token_batches|

          token_batches.each do |row|

          current_time = Time.now
          log_line "Starting iteration #{@iteration_count} at #{current_time}"

          performer_klass = @performer_klass.constantize.new({client_id: row.client_id,
                                                             token_id: row.id,
                                                             token_name: row.name})
          performer_klass.perform

          end

          @iteration_count += 1
          sleep(@sleep_interval) # sleep for @sleep_interval second after one iteration.

        end


      rescue Exception => e

        ApplicationMailer.notify(
          body: {exception: {message: e.message, backtrace: e.backtrace}},
          data: {},
          subject: "Exception in cron_task:check_low_balance:#{@process_name}"
        ).deliver

        log_line("Exception : <br/> #{CGI::escapeHTML(e.inspect)}<br/><br/><br/>Backtrace:<br/>#{CGI::escapeHTML(e.backtrace.inspect)}")

      ensure
        log_line("Ended at => #{Time.now} after #{@iteration_count} iterations")
      end
    end

    # Helper methods

    # Output logged lines
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def log_line(line)
      puts "cron_task:check_low_balance:#{@process_name} : #{line}"
    end

    # Start the cron job
    #
    # * Author: Anagha
    # * Date: 01/08/2019
    # * Reviewed By:
    #
    def execute_cron_task
      Rake::Task['cron_task:check_low_balance:execute_task'].reenable
      Rake::Task['cron_task:check_low_balance:execute_task'].invoke
      @lock_file_handle.close
    end

  end

end
