class BackgroundJob

  extend Sanitizer

  # Enqueue
  #
  # * Author: Kedar
  # * Date: 24/01/2018
  # * Reviewed By:
  #
  # @param [Class] klass (mandatory) - Class of the job to be enqueued
  # @param [Hash] enqueue_params (mandatory) - Class of the job to be enqueued
  # @param [Hash] options (optional) - Hash of the extra options - queue, force_run_sync, wait
  #
  def self.enqueue(klass, enqueue_params, options = {})
    # Set default values to options
    options.reverse_merge!({
                             emails: '',
                             subject: "[#{Rails.env}]: Exception occurred while trying to enqueue job to resque",
                             safe: true,
                             fallback_run_sync: true,
                             force_run_sync: false
                           })
    q_name = options[:queue] || klass.queue_name

    # if force_run_sync or if it is dev env, run the job synchronously
    if options[:force_run_sync]
      sleep(options[:wait]) if options[:wait].present?
      return perform_job_synchronously(klass, enqueue_params, q_name)
    else
      enqueue_params = hashify_params_recursively(enqueue_params)
      if options[:wait].present?
        klass.set(queue: q_name, wait: options[:wait]).perform_later(enqueue_params)
      else
        klass.set(queue: q_name).perform_later(enqueue_params)
      end
    end

  rescue => e

    Rails.logger.error("Resque enqueue failed with params #{enqueue_params}. Exception: #{e.message} Trace: #{e.backtrace}")
    sleep(options[:wait]) if options[:wait].present?

    if options[:fallback_run_sync]
      perform_job_synchronously(klass, enqueue_params, q_name)
    end

    ApplicationMailer.notify(
      body: {exception: {message: e.message, backtrace: e.backtrace}},
      data: {
        'enqueue_params' => enqueue_params,
        'class_name' => klass,
        'options' => options,
      },
      subject: 'Exception in Resque enqueue'
    ).deliver

  end

  # Perform job synchronously
  #
  # * Author: Kedar
  # * Date: 24/01/2018
  # * Reviewed By:
  #
  # @param [Class] klass (mandatory) - Class of the job to be enqueued
  # @param [Hash] enqueue_params (mandatory) - Class of the job to be enqueued
  # @param [String] q_name (mandatory) - queue name
  #
  def self.perform_job_synchronously(klass, enqueue_params, q_name)
    job = klass.new
    Rails.logger.info("Performing Job (#{job.class}) synchronously")
    job.queue_name = q_name
    job.perform(enqueue_params || {})
  rescue => e
    Rails.logger.error("Resque perform_job_synchronously failed with params #{enqueue_params}. Exception: #{e.message} Trace: #{e.backtrace}")

    ApplicationMailer.notify(
      body: {exception: {message: e.message, backtrace: e.backtrace}},
      data: {
        'enqueue_params' => enqueue_params,
        'class_name' => klass,
        'q_name' => q_name,
      },
      subject: 'Exception in perform_job_synchronously'
    ).deliver
  end

end