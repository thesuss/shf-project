# Common methods used by mailers. These can be included both in classes that
# must inherit from Devise::Mailer or ApplicationMailer (or any other mailer class).
module CommonMailUtils

  private

  def set_greeting_name(record)

    if record.respond_to?(:full_name)
      @greeting_name = "#{record.full_name}"
    elsif record.respond_to? :email
      @greeting_name = record.email
    end

  end


  def set_recipient_email(record)
    @recipient_email = record.email if record.respond_to? :email
  end


end
