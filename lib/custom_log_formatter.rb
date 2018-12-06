class CustomLogFormatter < ActiveSupport::Logger::SimpleFormatter

  # This method is invoked when a log event occurs
  def call(severity, timestamp, progname, msg)
    "#{severity} : #{$$} :  @#{timestamp.strftime('%F %T:%L')} : #{msg}\n"
  end

end