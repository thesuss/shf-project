# Abstract parent class for all alerts that send out emails to users
#
# Responsibility: sets the information needed so that the parent class(es) can
#  process the condition for an email sent to Users
#
#  SUBCLASSES MUST REDEFINE THESE METHODS:
#     send_alert_this_day?
#     mailer_method
#
class UserEmailAlert < EmailAlert


  def entities_to_check
    User.all
  end


  def mailer_class
    MemberMailer
  end


  def mailer_args(user)
    [user]
  end


  def success_str(user)
    user_info(user)
  end


  # Return a log string maker specific to this class and subclasses
  #
  def log_str_maker
    @@log_str_maker ||= AlertLogStrMaker.new(self, :success_str, :failure_str)
  end


  def failure_str(user)
    user_info(user)
  end


  def user_info(user)
    user.nil? ? "user is nil" : "to id: #{user.id} email: #{user.email}"
  end
end
