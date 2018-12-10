class ApplicationJob < ActiveJob::Base

  include Util::ResultHelper

  # Perform
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By:
  #
  around_perform do |job, block|
    begin
      Rails.logger.info "Worker started processing job (#{job.job_id})"
      block.call
      Rails.logger.info "Worker completed job (#{job.job_id})"
    rescue StandardError => se
      Rails.logger.info "Worker got exception in job #{job.job_id}) msg : #{se.message} trace : #{se.backtrace}"
      ApplicationMailer.notify(
        body: {exception: {message: se.message, backtrace: se.backtrace}},
        data: job.arguments,
        subject: "Exception in #{self.class}"
      ).deliver
    end
  end

end
