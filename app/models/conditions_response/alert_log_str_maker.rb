# Responsibility: Stores and calls the right methods from an Alert to generate the
#                 string to write to the log.
#
class AlertLogStrMaker

  attr :alert, :success_method, :failure_method


  # @param alert [EmailAlert] - the alert that this will log for
  # @param success_info_method [Symbol] - the method to send to the alert, with the log_args,
  #                                       on success
  # @param failure_info_method [Symbol] - the method to send to the alert, with the log_args,
  #                                       on failure
  def initialize(alert, success_info_method, failure_info_method)
    @alert          = alert
    @success_method = success_info_method
    @failure_method = failure_info_method
  end


  # Send the :success_method to the :alert with :log_args so that the
  # string can be generated that is written to the log
  #
  # @param log_args [Array] - the arguments to pass to the :success_method
  #    so that the :alert can generate the string needed
  #
  # @return [String] - the string to write to the log upon success
  def success_info(log_args)
    alert.send(success_method, *log_args)
  end


  # Send the :failure_method to the :alert with :log_args so that the
  # string can be generated that is written to the log
  #
  # @param log_args [Array] - the arguments to pass to the :failure_method
  #    so that the :alert can generate the string needed
  #
  # @return [String] - the string to write to the log upon success
  def failure_info(log_args)
    alert.send(failure_method, *log_args)
  end

end
