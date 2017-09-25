class ApplicationMailer < ActionMailer::Base

  include MailgunConfig

  include CommonMailUtils


  default from: ENV['SHF_NOREPLY_EMAIL']

  layout 'mailer'

  helper :application # gives access to all helpers defined within `application_helper`.


  def test_email(user)
    @action_name = __method__.to_s
    @greeting_name = set_greeting_name(user)

    mail to: set_recipient_email(user), subject: t('application_mailer.greeting', greeting_name: @greeting_name)

  end


end
