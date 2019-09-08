module OneTimeTasker

#--------------------------
#
# @class FailedTaskAttempt
#
# @desc Responsibility: A failed task attempt. :was_successful is always false
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-02
#
# @file failed_task_attempt
#
#--------------------------
  class FailedTaskAttempt < TaskAttempt
    IS_SUCCESSFUL_VALUE = false

    after_initialize :set_as_failed

    validates_inclusion_of :was_successful, in: [IS_SUCCESSFUL_VALUE],
                           message:             I18n.t('activerecord.errors.models.failed_task_attempt.attributes.was_successful.invalid')

    default_scope { where(was_successful: IS_SUCCESSFUL_VALUE) }


    def set_as_failed
      self.was_successful = IS_SUCCESSFUL_VALUE
      self.attempted_on   = Time.zone.now
    end

  end

end
