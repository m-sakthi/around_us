class ApplicationMailer < ActionMailer::Base
  default from: AppSettings[:support_email]
  layout 'mailer'
end
