namespace :cron_task do

  namespace :continuous do

    DEFAULT_RUNNING_INTERVAL = 1.hour

    # sample code for one to user a continuous running cron
    # Steps :
    # 1. set @process_name which would make the lock file name
    # 2. set @DEFAULT_RUNNING_INTERVAL, time for which we want to run one contininuos instance. If blank we default to DEFAULT_RUNNING_INTERVAL
    # 3. set @optional_params, if we want to pass them to initialize of performer_klass
    # 4. set @performer_klass with the name of a klass which
    #     its initializer should accept a hash key because cronjob will pass cronjob id to it
    #     and other optinal params
    #     Example: Search::Hooks::Processor.new()
    #     and implements perform method
    # 5. call execute_task method

    # Process Email Service API Call hooks
    #
    # * Author: Puneet
    # * Date: 22/01/2018
    # * Reviewed By:
    #
    desc "rake RAILS_ENV=development cron_task:continuous:process_email_service_api_call_hooks lock_key_suffix=1"
    desc "*/1 * * * * cd /mnt/kit-api/current && rake RAILS_ENV=staging cron_task:continuous:process_email_service_api_call_hooks lock_key_suffix=1 >> /mnt/kit-api/shared/log/process_email_service_api_call_hooks.log"
    task :process_email_service_api_call_hooks do |task|
      @sleep_interval = 2

      @process_name = "#{task}_#{ENV['lock_key_suffix']}"
      @performer_klass = 'Crons::HookProcessors::EmailServiceApiCall'
      @optional_params = {}
      execute_continuous_task
    end

    private

    # task which running a continuing instance of perform method in performer klass
    # also define the chain of tasks that need to run with every continuous cron
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By: Sunil
    #
    task :execute_task => [:validate_params, :acquire_lock, :set_up_environment] do

      begin

        @iteration_count = 1
        @running_interval ||= DEFAULT_RUNNING_INTERVAL
        @sleep_interval ||= 10 # In Seconds

        register_signal_handlers

        while @continue_running && (@start_time + @running_interval) > Time.now do

          current_time = Time.now
          log_line "Starting iteration #{@iteration_count} at #{current_time} with params: #{@params}"

          performer_klass = @performer_klass.constantize.new(@params)
          performer_klass.perform

          @iteration_count += 1
          sleep(@sleep_interval) # sleep for @sleep_interval second after one iteration.

        end

      rescue Exception => e

        ApplicationMailer.notify(
            body: {exception: {message: e.message, backtrace: e.backtrace}},
            data: {},
            subject: "Exception in cron_task:continuous:#{@process_name}"
        ).deliver

        log_line("Exception : <br/> #{CGI::escapeHTML(e.inspect)}<br/><br/><br/>Backtrace:<br/>#{CGI::escapeHTML(e.backtrace.inspect)}")

      ensure
        log_line("Ended at => #{Time.now} after #{@iteration_count} iterations")
      end
    end

    # hepler methods

    # output logged lines
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By: Sunil
    #
    def log_line(line)
      puts "cron_task:continuous:#{@process_name} : #{line}"
    end

    # Start the cron job
    # Called once. This internally sleeps for some time between processing multiple batches
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By: Sunil
    #
    def execute_continuous_task
      Rake::Task['cron_task:continuous:execute_task'].reenable
      Rake::Task['cron_task:continuous:execute_task'].invoke
      @lock_file_handle.close
    end

  end

end
