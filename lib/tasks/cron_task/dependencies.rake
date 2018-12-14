namespace :cron_task do

  # this file has code for dependent tasks for lockable and continuous cron_task

  private

  # a pre requisite task to execute_task which validates params
  #
  # * Author: Puneet
  # * Date: 10/10/2017
  # * Reviewed By: Sunil
  #
  task :validate_params do
    fail '@process_name blank' if @process_name.blank?
  end

  # a pre requisite task to execute_task which acquires file lock
  #
  # * Author: Puneet
  # * Date: 10/10/2017
  # * Reviewed By: Sunil
  #
  task :acquire_lock do
    log_line "Trying to acquire lock at => #{Time.now}"
    @lock_file_handle = File.open(lock_file_path, File::RDWR|File::CREAT, 0644)
    if @lock_file_handle.flock(File::LOCK_EX|File::LOCK_NB)
      log_line "acquired lock at => #{Time.now}"
    else
      log_line 'Not able to acquire a lock'
      fail "Not able to acquire a lock for #{@process_name}"
      exit!
    end
  end

  # a pre requisite task to execute_task which loads Rails Environment and sets some instance vars
  #
  # * Author: Puneet
  # * Date: 10/10/2017
  # * Reviewed By: Sunil
  #
  task :set_up_environment => :environment do
    # included this module to be able to register signal handlers
    include Util::SignalHandler

    @start_time = Time.now
    log_line "============= Loading Env at #{@start_time}"
    @params = {}
    @params.merge!(@optional_params) if @optional_params.present?
  end

  # Get the lock file name
  #
  # * Author: Puneet
  # * Date: 10/10/2017
  # * Reviewed By: Sunil
  #
  def lock_file_path
    @lock_file_path ||= "#{Rails.root.to_s}/log/#{@process_name}.lock"
  end

end