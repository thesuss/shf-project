#--------------------------
#
# @module ActivityLogTags
#
# @desc Responsibility: attributes and methods for accessing the
# 'facility' and 'activity' tags.
#   (e.g. used for ActivityLogger )
#
#  classes/modules that include this SHOULD overwrite the constants
#  to provide default values.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-11
#
#--------------------------
module ActivityLogTags

  DEFAULT_LOG_FACILITY_TAG = ''
  DEFAULT_LOG_ACTIVITY_TAG = ''


  attr_writer :log_facility_tag, :log_activity_tag


  def log_facility_tag
    @log_facility_tag ||= default_log_facility_tag
  end


  def log_activity_tag
    @log_activity_tag ||= default_log_activity_tag
  end


  # for resetting to the original default
  def default_log_facility_tag
    get_class_const_value(:DEFAULT_LOG_FACILITY_TAG)
  end


  # for resetting to the original default
  def default_log_activity_tag
    get_class_const_value(:DEFAULT_LOG_ACTIVITY_TAG)
  end


  private


  # if the including class has defined the constant, use that value
  # else use our value of the constant.
  def get_class_const_value(constant)
    the_including_class = self.class
    the_including_class.const_defined?(constant) ? the_including_class.const_get(constant) : constant
  end

end
