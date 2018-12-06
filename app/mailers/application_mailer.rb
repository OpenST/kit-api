class ApplicationMailer < ActionMailer::Base

  default from: GlobalConstant::Email.default_from

  def notify(params)
    to_email = params[:to] || GlobalConstant::Email.default_to
    @mail_body = params[:body].to_s
    @mail_data = Array.wrap(params[:data])
    subject = GlobalConstant::Email.subject_prefix + (params[:subject] || 'Notification Mail')
    (params[:attachments] || []).each do |attachment|
      attachments[attachment[:filename]] = File.read(attachment[:filepath])
    end
    mail(to: to_email, subject: subject)
  end

end
