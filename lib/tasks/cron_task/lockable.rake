namespace :cron_task do

  namespace :lockable do

    # sample code for one to user a continuous running cron
    # Steps :
    # 1. set @process_name which would make the lock file name
    # 2. set @optional_params, if we want to pass them to initialize of performer_klass
    # 3. set @performer_klass with the name of a klass which
    #     its initializer should accept a hash key because cronjob will pass cronjob id to it
    #     and other optinal params
    #     Example: Search::Hooks::Processor.new()
    #
    #     and implements perform method which takes current timestamp as an input ex : performer.perform(current_time.to_i)
    # 4. call execute_task method
    #

    private

    # task which running a continuing instance of perform method in performer klass
    # also define the chain of tasks that need to run with every continuous cron
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    task :execute_task => [:validate_params, :acquire_lock, :set_up_environment] do

      begin

        current_time = Time.now
        log_line "Starting at #{current_time} with params: #{@params}"
        performer_klass = @performer_klass.constantize.new(@params)
        performer_klass.perform

      rescue Exception => e

        ApplicationMailer.notify(
            body: {exception: {message: e.message, backtrace: e.backtrace}},
            data: {},
            subject: "Exception in cron_task:lockable:#{@process_name}"
        ).deliver

        log_line("Exception : <br/> #{CGI::escapeHTML(e.inspect)}<br/><br/><br/>Backtrace:<br/>#{CGI::escapeHTML(e.backtrace.inspect)}")

      ensure
        log_line("Ended at => #{Time.now} ")
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
      puts "cron_task:lockable:#{@process_name} : #{line}"
    end

    # Start the cron job and also make it available to be executed for next time in same iteration
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By: Sunil
    #
    def execute_lockable_task
      Rake::Task['cron_task:lockable:execute_task'].reenable
      Rake::Task['cron_task:lockable:execute_task'].invoke
      @lock_file_handle.close
    end

  end

end
