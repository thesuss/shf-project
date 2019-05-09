# Abstract parent class for all alerts that send out emails to admins
#
# Responsibility: sets the information needed so that the parent class(es) can
#  process the condition for an email sent to Admins
#
#  SUBCLASSES MUST IMPLEMENT SPECIFIC METHODS.
#  They must be implemented to satisfy the interface for this abstract class.
#  Any method that a subclass must implement will raise a NoMethod error
#  here in this class unless a subclass implements it.
#
#
class AdminEmailAlert < EmailAlert

  # add entities to the list that is used in the email sent to the Admins
  attr_accessor :entities_list


  def entities_list
    @entities_list ||= []
  end


  # Go through all entities and add any to the list of entities that we need to.
  # Then send email to all Admins with that list of entities as information.
  def process_entities(entities_to_check, log)

    @entities_list = []

    # get all of the users of interest
    entities_to_check.each { |entity| take_action(entity, log) }

    # send email to admins with the users of interest

    if !entities_list.empty? && send_alert_this_day?(@timing, @config)
      recipients.each do |admin|
        send_email(admin, log, [entities_list])
      end
    end

  end


  def entities_to_check
    User.not_admins
  end


  # This loops through the entities, but doesn't send email to them.
  # It loops through the entities to gather information and then sends email to admins.
  #
  def take_action(entity, _log)
    (entities_list.append(entity)) if add_entity_to_list?(entity)
  end


  # Subclasses must define this
  def add_entity_to_list?(_entity)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # Default is to send to all admins
  def recipients
    User.admins
  end


  # send an alert only if we send one every day OR if it is the right day of the month
  def send_alert_this_day?(timing, config)
    self.class.timing_matches_today?(timing, config)
  end


  def mailer_class
    AdminMailer
  end


  def mailer_args(admin)
    [admin, entities_list]
  end


  def success_str(admin)
    user_info(admin)
  end


  def failure_str(admin)
    user_info(admin)
  end


  # ------------------------


  private


  def user_info(admin)
    admin.nil? ? "admin is nil" : "to id: #{admin.id} email: #{admin.email}"
  end

end
